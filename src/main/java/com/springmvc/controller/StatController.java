// 글로벌을 제외한 모든 통계 페이지
package com.springmvc.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.springmvc.service.StatService;

@Controller
@RequestMapping("/stats") 
public class StatController {

	 @Autowired
	    private StatService statService;

	    @GetMapping("/initGenres")
	    @ResponseBody
	    public String initMovieGenres() {
	        statService.initializeMovieGenres();
	        return "movie_genres 테이블 초기화 완료!";
	    }

}
