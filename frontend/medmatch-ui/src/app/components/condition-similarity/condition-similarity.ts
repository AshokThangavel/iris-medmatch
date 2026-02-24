
import { Component, ChangeDetectorRef } from '@angular/core'; // Added ChangeDetectorRef
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-condition-similarity',
  standalone: false,
  templateUrl: './condition-similarity.html',
  styleUrls: ['./condition-similarity.component.css']
})

export class ConditionSimilarity {
  searchTerm: string = '';
  allResults: any[] = [];    // Store the full response here
  paginatedResults: any[] = []; // Store only the current page here
  loading: boolean = false;
  statusMessage: string = '';
  protected readonly Math = Math;

  // Pagination Variables
  currentPage: number = 1;
  pageSize: number = 10;
  totalPages: number = 0;

  private apiUrl = 'http://localhost:52773/medmatch/api/search';

  constructor(private http: HttpClient, private cdr: ChangeDetectorRef) { }

  onSearch() {
    if (!this.searchTerm.trim()) {
      this.statusMessage = "Please enter a search term.";
      return;
    }

    this.loading = true;
    this.allResults = [];
    this.paginatedResults = [];
    this.currentPage = 1; // Reset to page 1 on new search
    this.statusMessage = "AI Engine is calculating vectors...";

    const fullUrl = `/medmatch/api/search?text=${encodeURIComponent(this.searchTerm)}`;

    this.http.get<any[]>(fullUrl).subscribe({
      next: (response) => {
        this.allResults = response;
        this.updatePagination(); // Split the data
        this.loading = false;
        this.statusMessage = response.length === 0 ? "No similar patients found." : "";
        this.cdr.detectChanges();
      },
      error: (err) => {
        this.loading = false;
        this.statusMessage = "Search failed. Ensure IRIS is running.";
        this.cdr.detectChanges();
      }
    });
  }

  // Logic to calculate the slice of data
  updatePagination() {
    this.totalPages = Math.ceil(this.allResults.length / this.pageSize);
    const startIndex = (this.currentPage - 1) * this.pageSize;
    const endIndex = startIndex + this.pageSize;
    this.paginatedResults = this.allResults.slice(startIndex, endIndex);
  }

  goToPage(page: number) {
    if (page >= 1 && page <= this.totalPages) {
      this.currentPage = page;
      this.updatePagination();
      this.cdr.detectChanges();
    }
  }

  getScoreClass(similarity: number): string {
    const score = similarity * 100;
    if (score >= 80) return 'high-score';
    if (score >= 50) return 'med-score';
    return 'low-score';
  }
}