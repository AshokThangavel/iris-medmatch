import { Component, ChangeDetectorRef } from '@angular/core';
import { FhirService } from '../../services/fhir.service';

@Component({
  selector: 'app-patient-create',
  standalone: false,
  templateUrl: './patient-create.html',
  styleUrls: ['./patient-create.component.css']
})
export class PatientCreateComponent {
  firstName = '';
  middleName = '';
  lastName = '';
  gender = 'unknown';

  errorMessage: string | null = null; // Add this to your class variables
  dob: string = '';
  today: string = new Date().toISOString().split('T')[0];

  constructor(private fhirService: FhirService, private cdr: ChangeDetectorRef) { }

  submitPatient() {
    const patientResource = {
      resourceType: "Patient",
      name: [{
        use: "official",
        family: this.lastName,
        given: [this.firstName, this.middleName].filter(n => n !== '') // Only add names if they exist
      }],
      gender: this.gender,
      birthDate: this.dob
    };
    this.fhirService.createPatient(patientResource).subscribe({
      next: (res: any) => {
        alert(`Patient filed successfully!`);
        this.errorMessage = null; // Clear any old errors
        this.clearForm();
        this.cdr.detectChanges();
      },
      error: (err: any) => {
        if (err.error && err.error.resourceType === 'OperationOutcome') {
          this.errorMessage = err.error.issue
            .map((issue: any) => `• ${issue.details?.text || issue.diagnostics}`)
            .join('\n');
        } else {
          // Fallback for generic connection errors
          this.errorMessage = "An unexpected error occurred while saving to IRIS.";
        }
        this.cdr.detectChanges();
      }
    });
  }
  clearForm() {
    this.firstName = '';
    this.middleName = '';
    this.lastName = '';
    this.gender = 'unknown';
    this.dob = '';
  }
}