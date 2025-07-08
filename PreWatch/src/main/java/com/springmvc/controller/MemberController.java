package com.springmvc.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;

import com.springmvc.domain.Member;
import com.springmvc.service.MemberService;

@Controller
public class MemberController {
	
	@Autowired
	 private MemberService memberService;
	
	//회원가입 폼으로 이동합니다.
	@GetMapping("/join") // joinForm.jsp 보여주기
	public String showJoinForm(Model model) {
		System.out.println("/Join 매핑. joinForm.jsp 로 이동");
	    model.addAttribute("member", new Member());  // 선택사항
	    return "joinForm"; //
	}
	
	//회원가입 정보 전달폼.
	@PostMapping("/join") // joinResult.jsp로 처리 결과 넘기기
	public String processJoin(@ModelAttribute Member member) {
		System.out.println("/Join 매핑. joinForm.jsp 로 이동");
	    System.out.println(member);  // 디버깅용 출력 (id, password 확인)
	    memberService.save(member); // 서비스에 회원 객체 전달 → DB 저장
	    return "joinResult";  
	}

}
