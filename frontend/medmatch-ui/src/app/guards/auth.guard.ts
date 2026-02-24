import { inject } from '@angular/core';
import { Router, CanActivateFn } from '@angular/router';

export const authGuard: CanActivateFn = (route, state) => {
    const router = inject(Router);
    const isAuthenticated = !!localStorage.getItem('fhir_auth');

    if (isAuthenticated) {
        return true;
    } else {
        // Redirect to login if no auth found
        return router.parseUrl('/login');
    }
};