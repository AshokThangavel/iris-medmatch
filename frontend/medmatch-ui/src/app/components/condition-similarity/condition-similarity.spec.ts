import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ConditionSimilarity } from './condition-similarity';

describe('ConditionSimilarity', () => {
  let component: ConditionSimilarity;
  let fixture: ComponentFixture<ConditionSimilarity>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ConditionSimilarity]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ConditionSimilarity);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
