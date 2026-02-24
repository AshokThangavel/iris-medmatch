import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { NgModule } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class FhirService {
  private authHeader = '';
  private baseUrl = '/csp/healthshare/medmatch/fhir/r4';

  constructor(private http: HttpClient) { }

  setAuth(username: string, password: string) {
    const credentials = btoa(`${username}:${password}`);
    this.authHeader = `Basic ${credentials}`;
    localStorage.setItem('fhir_auth', credentials);
  }

  create(resourceType: string, data: any) {
    return this.http.post(`${this.baseUrl}/${resourceType}`, data, {
      headers: this.getRequestHeaders(),
      observe: 'response',
    });
  }
  createPatient(patientData: any) {
    return this.http.post(`${this.baseUrl}/Patient`, patientData, {
      headers: this.getRequestHeaders()
    });
  }

  search(query: string) {
    const url = `${this.baseUrl}${query}`;
    return this.http.get(url, {
      withCredentials: false,
      headers: this.getRequestHeaders()
    });
  }

  generateConditionVector(payload: any) {
    return this.http.post('/medmatch/api/condition-vectors', payload, {
      headers: { 'Content-Type': 'application/json' }
    });
  }

  private getRequestHeaders(): HttpHeaders {
    if (!this.authHeader) {
      const stored = localStorage.getItem('fhir_auth');
      if (stored) this.authHeader = `Basic ${stored}`;
    }

    return new HttpHeaders({
      'Authorization': this.authHeader,
      'Content-Type': 'application/fhir+json',
      'Accept': 'application/fhir+json'
    });
  }

}