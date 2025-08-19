package com.wipro.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name="customer")

public class Customer {

	@Id
  private int custid;
  private String name;
  
}
