package com.springmvc.domain;

// Member 클래스: 애플리케이션의 사용자(회원) 정보를 담는 도메인 클래스.
// 목적: 회원 가입, 로그인, 정보 수정 등 회원 관련 데이터 주고받기.
public class Member {
	private String id;       // 회원의 고유 아이디 (PRIMARY KEY)
	private String password; // 회원의 비밀번호
	private String role;     // 회원의 권한(역할)

	// 매개변수 생성자: 모든 필드 값을 받아 초기화 (role 필드 포함).
	public Member(String id, String password, String role) {
		super();
		this.id = id;
		this.password = password;
		this.role = role;
	}

	// 기본 생성자: 매개변수 없이 객체 생성. Spring MVC 폼 바인딩 등에 사용.
	public Member() {}

	// Getter/Setter: private 필드에 안전하게 접근하고 값을 설정. (role 필드 포함)
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

	public String getRole() { // role Getter
		return role;
	}
	public void setRole(String role) { // role Setter
		this.role = role;
	}

	// toString 메서드: 객체 상태를 문자열로 반환 (디버깅/로그 출력용, role 포함).
	@Override
	public String toString() {
		return "Member [id=" + id + ", password=" + password + ", role=" + role + "]";
	}
}