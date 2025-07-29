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
    
 // ✅ 배우 상세 페이지
    @GetMapping("/actors/{id}")
    public String actorDetail(@PathVariable Long id, Model model) {
        Map<String, Object> actor = actorRepository.findActorDetail(id);
        model.addAttribute("actor", actor);
        return "movie/actor_list"; // ✅ 꼬리님이 쓰는 뷰 이름으로 통일
    }

    // ✅ 감독 상세 페이지 (같은 뷰)
    @GetMapping("/directors/{id}")
    public String directorDetail(@PathVariable Long id, Model model) {
        Map<String, Object> director = actorRepository.findActorDetail(id);
        model.addAttribute("actor", director);
        return "movie/actor_list"; // ✅ 동일한 JSP
    }
    
    // ✅ DB에 저장된 출연진 전체 (배우+감독)
    @GetMapping("/movies/{id}/cast")
    public String castFromDatabase(@PathVariable Long id, Model model) {
        List<Map<String, Object>> dbCastList = actorRepository.findCastAndCrewByMovieId(id);
        model.addAttribute("dbCastList", dbCastList);
        return "movie/actor_list"; // 배우/감독 출력 전용 JSP
    }




    
    @GetMapping("/movies/{id}/cast/tmdb")
    public String castFromTmdb(@PathVariable Long id, Model model) {
        movie movie = movieService.findById(id);
        if (movie == null || movie.getApiId() == null) {
            return "redirect:/error"; // 안전 체크
        }

        Integer tmdbId = tmdbApiService.getTmdbMovieId(movie.getApiId());
        if (tmdbId == null) {
            return "redirect:/error";
        }

        List<Map<String, String>> tmdbCastList = tmdbApiService.getCastAndCrew(tmdbId);
        model.addAttribute("tmdbCastList", tmdbCastList);

        return "movie/actor_list"; // 배우/감독 출력 전용 JSP
    }

}