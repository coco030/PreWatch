package com.springmvc.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class HomeController {
	public HomeController() {
		System.out.println("public HomeController생성자 Controller 객체 생성완료");
	}
	@RequestMapping("/")
	public String main()
	{	
		return "home";
	}
}