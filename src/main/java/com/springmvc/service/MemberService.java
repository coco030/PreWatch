package com.springmvc.service;

import com.springmvc.domain.Member; // Member 도메인 클래스

// MemberService 인터페이스: 회원(Member) 관련 비즈니스 로직 메서드 정의.
// 목적: Controller와 Repository 사이에서 비즈니스 규칙 적용 및 트랜잭션 관리.
public interface MemberService {
    // 새 회원 정보 저장 (예: 중복 아이디 확인 후 저장).
    void save(Member member);

    // 주어진 ID의 회원 존재 여부 확인 (예: 회원가입 시 아이디 중복 검사).
    boolean existsById(String id);

    // ID와 비밀번호로 로그인 시도, 성공 시 Member 객체 반환 (예: 사용자 인증).
    Member login(String id, String password);

    // 특정 회원의 비밀번호 변경 (예: 유효성 검사 후 변경).
    void updatePassword(String id, String pw);

    // 특정 회원을 비활성화 (예: 회원 탈퇴 처리).
    void deactivate(String id); // 
}