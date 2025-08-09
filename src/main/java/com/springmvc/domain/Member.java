package com.springmvc.domain;

public class Member {
	private String id;       // 회원의 고유 아이디 (PRIMARY KEY)
	private String password; // 회원의 비밀번호
	private String role;     // 회원의 권한(역할)
	
	private String tasteTitle; 
    private String tasteReport;      
    private Double tasteAnomalyScore;  

	public Member(String id, String password, String role, String tasteTitle, String tasteReport,
			Double tasteAnomalyScore) {
		super();
		this.id = id;
		this.password = password;
		this.role = role;
		this.tasteTitle = tasteTitle;
		this.tasteReport = tasteReport;
		this.tasteAnomalyScore = tasteAnomalyScore;
	}


	public String getTasteTitle() {
		return tasteTitle;
	}


	public void setTasteTitle(String tasteTitle) {
		this.tasteTitle = tasteTitle;
	}


	public String getTasteReport() {
		return tasteReport;
	}


	public void setTasteReport(String tasteReport) {
		this.tasteReport = tasteReport;
	}


	public Double getTasteAnomalyScore() {
		return tasteAnomalyScore;
	}


	public void setTasteAnomalyScore(Double tasteAnomalyScore) {
		this.tasteAnomalyScore = tasteAnomalyScore;
	}

	public Member() {}
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

	public String getRole() { 
		return role;
	}
	public void setRole(String role) { 
		this.role = role;
	}

	@Override
	public String toString() {
		return "Member [id=" + id + ", password=" + password + ", role=" + role + ", tasteTitle=" + tasteTitle
				+ ", tasteReport=" + tasteReport + ", tasteAnomalyScore=" + tasteAnomalyScore + "]";
	}
}