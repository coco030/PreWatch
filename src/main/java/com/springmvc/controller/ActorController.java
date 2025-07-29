package com.springmvc.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import com.springmvc.domain.movie;
import com.springmvc.repository.ActorRepository;
import com.springmvc.service.TmdbApiService;
import com.springmvc.service.movieService;

@Controller
public class ActorController {
	
	@Autowired
	private movieService movieService;

    @Autowired
    private ActorRepository actorRepository;

    @Autowired
    private TmdbApiService tmdbApiService;
    
    
    // 출연진 상세 정보
    @GetMapping({"/actors/{id}", "/directors/{id}"})
    public String actorOrDirectorDetail(@PathVariable Long id, Model model) {
        Map<String, Object> person = actorRepository.findActorDetail(id);
        model.addAttribute("actor", person);

        // 추가: 출연/제작 참여 영화 목록
        List<Map<String, Object>> movieList = actorRepository.findMoviesByActorId(id);
        model.addAttribute("movieList", movieList);

        return "movie/actor_detail"; // 공통 뷰
    }

}