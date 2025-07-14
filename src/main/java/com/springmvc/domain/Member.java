package com.springmvc.domain;

public class Member {
	private String id;
	private String password;
	
	// 1. 매개변수 생성자
	public Member(String id, String password) {
		super();
		this.id = id;
		this.password = password;
	}
	// 2. 기본 생성자
	public Member() {}
	
	// 3. Getter/Setter
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
	// 4. toString 메서드
	@Override
	public String toString() {
		return "Member [id=" + id + ", password=" + password + "]";
	}
}