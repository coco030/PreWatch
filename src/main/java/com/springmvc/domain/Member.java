package com.springmvc.domain;

public class Member {
	private String id;
	private String password;
	
	// 1. 기본 생성자 생성.
	public Member() {}

	public String getId() {
		return id;
	}

	// 2. getter/setter 생성
	public void setId(String id) {
		this.id = id;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}
	// 3. ToString 생성

	@Override
	public String toString() {
		return "Member [id=" + id + ", password=" + password + "]";
	}

}
