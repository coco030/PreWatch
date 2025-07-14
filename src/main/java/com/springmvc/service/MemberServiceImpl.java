package com.springmvc.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.springmvc.domain.Member;
import com.springmvc.repository.MemberRepository;
@Service
public class MemberServiceImpl implements MemberService{
	
	@Autowired
    private MemberRepository memberRepository;


	public void save(Member member) {
		memberRepository.save(member);
		System.out.println("[Service] 회원 저장 시도: ID = " + member.getId());
		
	}
	@Override
	public Member login(String id, String password) {
	    return memberRepository.login(id, password);
	}

    // 가입시 중복 아이디를 넣는지 검사 로직 
	@Override
    public boolean existsById(String id) {
        return memberRepository.existsById(id); 
    }
	
	@Override
	public void updatePassword(String id, String pw) {
	    System.out.println("[Service] updatePassword() 호출됨");
	    System.out.println("[Service] 전달된 id = " + id + ", pw = " + pw);

	    memberRepository.updatePassword(id, pw);

	    System.out.println("[Service] memberRepository.updatePassword() 호출 완료");
	}
	
	//회원비활성화
	@Override
	public void deactivate(String id) {
		memberRepository.deactivate(id);
	}

}