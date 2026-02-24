import { Component } from '@angular/core';
import { Router } from '@angular/router'; // 1. Import Router
import { FhirService } from '../../services/fhir.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.html',
  standalone: false,
  styleUrls: ['./login.component.css']
})
export class LoginComponent {
  username = '';
  password = '';

  constructor(
    private fhirService: FhirService,
    private router: Router // 2. Inject Router
  ) { }

  login() {
    if (this.username && this.password) {
      this.fhirService.setAuth(this.username, this.password);
      this.router.navigate(['/condition-similarity']);
    } else {
      alert('Please enter both username and password');
    }
  }
}