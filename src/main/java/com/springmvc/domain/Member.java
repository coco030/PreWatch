package com.springmvc.domain;

public class Member {
	private String id;
	private String password;
	private String role; // ⭐ 새롭게 추가된 role 필드

	// 1. 매개변수 생성자 (role 필드 추가에 따라 수정)
	public Member(String id, String password, String role) { // role 매개변수 추가
		super();
		this.id = id;
		this.password = password;
		this.role = role; // role 초기화
	}

	// 2. 기본 생성자
	public Member() {}

	// 3. Getter/Setter (role 필드에 대한 Getter/Setter 추가)
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getPassword() {
		return password;
	}
	public void setPassword(String password) {
		this.password = password;
	}

	// ⭐ role 필드에 대한 Getter/Setter 추가
	public String getRole() {
		return role;
	}
	public void setRole(String role) {
		this.role = role;
	}

	// 4. toString 메서드 (role 필드 추가에 따라 수정)
	@Override
	public String toString() {
		return "Member [id=" + id + ", password=" + password + ", role=" + role + "]";
	}
}