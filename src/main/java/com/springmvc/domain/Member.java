<<<<<<< HEAD
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
=======
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
>>>>>>> 4bceb7925953eb4af9533b02996141ec23f73d07
