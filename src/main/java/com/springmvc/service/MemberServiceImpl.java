package com.springmvc.service;

import org.springframework.beans.factory.annotation.Autowired; 
import org.springframework.stereotype.Service;                 

import com.springmvc.domain.Member;                         
import com.springmvc.repository.MemberRepository;             

// MemberServiceImpl 클래스: MemberService 인터페이스 구현.
// 목적: 회원 관련 비즈니스 로직 실제 구현. MemberRepository에 데이터베이스 상호작용 위임.

@Service // Spring 빈으로 등록
public class MemberServiceImpl implements MemberService{

	@Autowired
    private MemberRepository memberRepository; // MemberRepository 주입 (실제로는 MemberRepositoryImpl)

    // save 메서드: 회원 정보 저장.
    // 목적: Controller에서 호출, 실제 저장 작업은 MemberRepository에 위임.
	public void save(Member member) {
		memberRepository.save(member);
		System.out.println("[Service] 회원 저장 시도: ID = " + member.getId());
	}

	// login 메서드: 로그인 로직 처리.
	// 목적: Controller에서 사용자 ID/비밀번호 받아 MemberRepository에 인증 위임.
	@Override
	public Member login(String id, String password) {
	    return memberRepository.login(id, password);
	}

    // existsById 메서드: 아이디 중복 검사.
    // 목적: Controller에서 호출, 실제 중복 확인은 MemberRepository에 위임.
	@Override
    public boolean existsById(String id) {
        return memberRepository.existsById(id);
    }

	// updatePassword 메서드: 비밀번호 변경 로직 처리.
	// 목적: Controller에서 새 비밀번호 정보 받아 MemberRepository에 업데이트 요청.
	@Override
	public void updatePassword(String id, String pw) {
	    System.out.println("[Service] updatePassword() 호출됨");
	    System.out.println("[Service] 전달된 id = " + id + ", pw = " + pw);

	    memberRepository.updatePassword(id, pw);

	    System.out.println("[Service] memberRepository.updatePassword() 호출 완료");
	}

	// deactivate 메서드: 회원 비활성화.
	// 목적: Controller에서 호출, 실제 비활성화는 MemberRepository에 위임.
	@Override
	public void deactivate(String id) {
		memberRepository.deactivate(id);
	}
}