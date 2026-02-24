import { Component, ChangeDetectorRef } from '@angular/core'; // Added ChangeDetectorRef
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
  standalone: false
})
export class AppComponent {
  searchTerm: string = '';
  results: any[] = [];
  loading: boolean = false;
  statusMessage: string = '';

  isLoginPage(): boolean {
    return this.router.url === '/login' || this.router.url === '/';
  }

  logout() {
    localStorage.removeItem('fhir_auth'); // Clear credentials
    this.router.navigate(['/login']);    // Redirect back to login
  }

  private apiUrl = 'http://localhost:52773/medmatch/api/search';

  constructor(
    private http: HttpClient,
    private cdr: ChangeDetectorRef, // 1. Inject the Change Detector
    private router: Router
  ) { }

  onSearch() {
    if (!this.searchTerm.trim()) {
      this.statusMessage = "Please enter a search term.";
      return;
    }

    this.loading = true;
    this.results = [];
    this.statusMessage = "AI Engine is calculating vectors...";



    const fullUrl = `${this.apiUrl}?text=${encodeURIComponent(this.searchTerm)}`;

    this.http.get<any[]>(fullUrl).subscribe({
      next: (response) => {
        // 2. Use spread operator to ensure Angular sees a NEW array reference
        this.results = [...response];
        this.loading = false;

        if (this.results.length === 0) {
          this.statusMessage = "No similar patients found.";
        } else {
          this.statusMessage = "";
        }

        // 3. Force the UI to refresh NOW
        this.cdr.detectChanges();
      },
      error: (err) => {
        this.loading = false;
        this.statusMessage = "Search failed. Ensure IRIS is running and CORS is enabled.";
        console.error("API Error:", err);

        // Ensure error message also shows up
        this.cdr.detectChanges();
      }
    });
  }
  getScoreClass(similarity: number): string {
    const score = similarity * 100;
    if (score >= 80) return 'high-score';
    if (score >= 50) return 'med-score';
    return 'low-score';
  }

}