import { TestBed } from '@angular/core/testing';

import { Fhir } from './fhir';

describe('Fhir', () => {
  let service: Fhir;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(Fhir);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
