package com.springmvc.repository;

import com.springmvc.domain.Member;

public interface MemberRepository {
	
	//회원 정보를 저장하기
	void save(Member member);

}
