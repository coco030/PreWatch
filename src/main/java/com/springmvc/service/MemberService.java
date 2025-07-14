package com.springmvc.service;


import com.springmvc.domain.Member;

public interface MemberService {
	 void save(Member member);  // 회원 저장 메서드
	 boolean existsById(String id); // 아이디 중복 확인
	 Member login(String id, String password);
	 void updatePassword(String id, String pw); //비밀번호 변경
	 void deactivate(String pid); //회원 비활성화
}