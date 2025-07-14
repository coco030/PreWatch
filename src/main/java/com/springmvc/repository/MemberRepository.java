<<<<<<< HEAD
package com.springmvc.repository;

import com.springmvc.domain.Member;

public interface MemberRepository {
    void save(Member member);// 회원 정보를 DB에 저장
    Member login(String id, String password); //로그인하기
    boolean existsById(String id); // 회원가입 시 중복된 ID가 있는지 확인 (DB 조회 기반의 비즈니스 유효성 검사)
	void updatePassword(String id, String pw);//비밀번호 변경
	void deactivate(String id); //회원 비활성화
}
=======
package com.springmvc.repository;

import com.springmvc.domain.Member;

public interface MemberRepository {
    void save(Member member);// 회원 정보를 DB에 저장
    Member login(String id, String password);
    boolean existsById(String id); // 회원가입 시 중복된 ID가 있는지 확인 (DB 조회 기반의 비즈니스 유효성 검사)
	void updatePassword(String id, String pw);//비밀번호 변경
}
>>>>>>> 4bceb7925953eb4af9533b02996141ec23f73d07
