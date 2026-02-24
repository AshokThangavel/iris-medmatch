import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { FhirService } from '../../services/fhir.service';

@Component({
  selector: 'app-patient-list',
  templateUrl: './patient-list.component.html',
  styleUrls: ['./patient-list.component.css'],
  standalone: false
})
export class PatientListComponent implements OnInit {
  patients: any[] = [];
  loading = false;

  // Pagination tracking
  nextUrl: string | null = null;
  prevUrl: string | null = null;
  totalRecords = 0;

  selectedPatient: any = null;

  selectedPatientId: string | null = null;
  activeAction: string | null = null;

  processingMessage: string = '';


  // Initial state for a new condition
  newCondition = {
    clinicalStatus: 'active',
    severity: '255604002',
    display: ''
  };


  constructor(private fhirService: FhirService, private cdr: ChangeDetectorRef) { }

  ngOnInit() {
    this.loadPatients('/Patient?_sort=_lastUpdated&_count=12');
  }

  openModal(patient: any, action: string) {
    this.selectedPatient = patient;
    this.activeAction = action;
    // Reset form when opening
    this.newCondition.display = '';
  }

  closeModal() {
    this.selectedPatient = null;
    this.activeAction = '';
  }

  selectPatient(patient: any, actionType: string) {
    // If clicking the same action again, close it
    if (this.selectedPatientId === patient.id && this.activeAction === actionType) {
      this.selectedPatientId = null;
      this.activeAction = null;
    } else {
      this.selectedPatientId = patient.id;
      this.activeAction = actionType;
    }
  }

  saveCondition() {
    if (!this.newCondition.display) return;

    this.loading = true;

    const resource = {
      resourceType: "Condition",
      clinicalStatus: {
        coding: [{
          system: "http://terminology.hl7.org/CodeSystem/condition-clinical",
          code: this.newCondition.clinicalStatus
        }]
      },
      code: { text: this.newCondition.display },
      subject: { reference: `Patient/${this.selectedPatient.id}` },
      recordedDate: new Date().toISOString()
    };

    this.fhirService.create('Condition', resource).subscribe({
      next: (resp: any) => {
        // 1. Extract the ID from the Location Header
        const loc = resp.headers.get('Location');
        const newId = loc?.split('Condition/')[1]?.split('/')[0];

        if (newId) {
          this.processingMessage = "Condition created! Generating AI Similarity Vector...";
          this.cdr.detectChanges();
          // CALL the vector method and SUBSCRIBE to wait for it
          this.generateVectorAndStore(newId, this.newCondition.display).subscribe({
            next: () => {
              this.processingMessage = "Vector stored! Finalizing...";
              this.finalizeSuccess();
            },
            error: (err) => {
              console.error("Vector failed:", err);
              // Even if vector fails, the FHIR record is saved.
              // You might want to close anyway or show a partial success.
              this.finalizeSuccess();
            }
          });
        } else {
          this.finalizeSuccess();
        }
      },
      error: (err) => {
        // Handling 201 Created even if it hits the error block
        if (err.status === 201) {
          const loc = err.headers.get('Location');
          const newId = loc?.split('Condition/')[1]?.split('/')[0];
          if (newId) this.generateVectorAndStore(newId, this.newCondition.display);
          this.handleSuccess();
        } else {
          this.loading = false;
          alert("Failed to save to FHIR server.");
        }
      }
    });
  }
  private generateVectorAndStore(newId: string, conditionText: string) {
    const vectorRequest = {
      fhirId: newId,
      textToEmbed: conditionText,
      resourceType: 'Condition'
    };
    return this.fhirService.generateConditionVector(vectorRequest);
  }

  private finalizeSuccess() {
    this.loading = false;
    this.closeModal();
    this.cdr.detectChanges(); // Ensure UI updates
    alert("Clinical record and AI Vector processed!");
  }

  // Helper to clean up the UI after save
  private handleSuccess() {
    this.loading = false;
    alert('condition added successfully');
    this.closeModal();
    this.cdr.detectChanges();
  }
  loadPatients(query?: string) {
    if (!query) return;

    this.loading = true;

    this.fhirService.search('/' + query).subscribe({
      next: (bundle: any) => {
        try {
          this.patients = bundle.entry?.map((e: any) => e.resource) || [];
          this.totalRecords = bundle.total || 0;

          this.nextUrl = this.getLink(bundle, 'next');
          this.prevUrl = this.getLink(bundle, 'previous');

        } catch (e) {
          console.error('Error processing bundle:', e);
        } finally {

          this.loading = false;
          this.cdr.detectChanges();
        }
      },
      error: (err) => {
        console.error('Search failed', err);
        this.loading = false;
        this.cdr.detectChanges();
      }
    });
  }
  // Helper to extract the relative URL from FHIR links for the proxy
  private getLink(bundle: any, relation: string): string | null {
    const link = bundle.link?.find((l: any) => l.relation === relation);
    if (!link) return null;

    // This approach is safer: It finds the start of the FHIR path
    // and keeps everything after it.
    const marker = '/fhir/r4/';
    const index = link.url.indexOf(marker);

    if (index !== -1) {
      return link.url.substring(index + marker.length);
    }

    // Fallback: If marker not found, try to just take the query part
    const urlParts = link.url.split('?');
    return urlParts.length > 1 ? `Patient?${urlParts[1]}` : null;
  }
}