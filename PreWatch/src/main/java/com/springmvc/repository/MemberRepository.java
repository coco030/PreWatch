package com.springmvc.repository;

import com.springmvc.domain.Member;

public interface MemberRepository {
	// 회원 정보를 DB에 저장
    void save(Member member);
    Member login(String id, String password);

    // 회원가입 시 중복된 ID가 있는지 확인 (DB 조회 기반의 비즈니스 유효성 검사)
    boolean existsById(String id);
	
}
