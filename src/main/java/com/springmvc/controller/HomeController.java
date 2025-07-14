<<<<<<< HEAD
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
=======
package com.springmvc.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

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
>>>>>>> 4bceb7925953eb4af9533b02996141ec23f73d07
