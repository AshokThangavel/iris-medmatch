import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule } from '@angular/common/http';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common'; // <--- Add this for [ngClass]
import { RouterModule, Routes } from '@angular/router';

import { AppComponent } from './app.component';
import { LoginComponent } from './components/login/login.component';
import { PatientCreateComponent } from './components/patient-create/patient-create.component';
import { PatientListComponent } from './components/patient-list/patient-list.component';
import { authGuard } from './guards/auth.guard';
import { ConditionSimilarity } from './components/condition-similarity/condition-similarity';


const routes: Routes = [
  { path: 'login', component: LoginComponent },
  {
    path: 'new-patient',
    component: PatientCreateComponent,
    canActivate: [authGuard]
  },
  {
    path: 'patient-list',
    component: PatientListComponent,
    canActivate: [authGuard]
  },
  {
    path: 'condition-similarity',
    component: ConditionSimilarity,
    canActivate: [authGuard]
  },
  { path: '', redirectTo: '/login', pathMatch: 'full' },
  { path: '**', redirectTo: '/login' } // Catch-all for 404s
];

@NgModule({
  declarations: [
    AppComponent,
    LoginComponent,
    PatientListComponent,
    PatientCreateComponent,
    ConditionSimilarity
  ],
  imports: [
    BrowserModule,
    FormsModule,
    HttpClientModule,   // <--- Add here
    CommonModule,        // <--- Add here
    RouterModule.forRoot(routes)
  ],
  providers: [],
  bootstrap: [AppComponent] // Corrected name
  ,
  exports: [RouterModule]
})
export class AppModule { }