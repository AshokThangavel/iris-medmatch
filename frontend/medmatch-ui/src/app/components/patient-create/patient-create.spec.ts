import { ComponentFixture, TestBed } from '@angular/core/testing';

import { PatientCreate } from './patient-create.component';

describe('PatientCreate', () => {
  let component: PatientCreate;
  let fixture: ComponentFixture<PatientCreate>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [PatientCreate]
    })
      .compileComponents();

    fixture = TestBed.createComponent(PatientCreate);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
