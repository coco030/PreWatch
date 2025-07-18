package com.springmvc.repository;

import com.springmvc.domain.Member; // Member 도메인 클래스

// MemberRepository 인터페이스: 회원 데이터 접근(CRUD) 메서드 정의.
// 목적: 데이터베이스 상호작용의 '계약' 역할. 서비스 계층에서 일관된 데이터 접근 제공.
public interface MemberRepository {
    // 회원 정보 DB에 저장 (C - Create)
    void save(Member member);

    // ID, 비밀번호 일치 및 'ACTIVE' 상태인 회원 정보 반환 (R - Read)
    Member login(String id, String password);

    // ID 중복 여부 확인
    boolean existsById(String id);

    // 특정 회원 비밀번호 업데이트 (U - Update)
    void updatePassword(String id, String pw);

    // 회원 상태 'INACTIVE'로 변경 (U - Update, 논리적 삭제)
    void deactivate(String id);
}