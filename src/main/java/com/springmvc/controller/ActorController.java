package com.springmvc.controller;

public class ActorController {
	
	
	@GetMapping("/actors/{id}")
	public String actorDetail(@PathVariable Long id, Model model) {
	    Map<String, Object> actor = actorRepository.findActorDetail(id);
	    model.addAttribute("actor", actor);
	    return "actor/detail"; // /WEB-INF/views/actor/detail.jsp
	}

	@GetMapping("/directors/{id}")
	public String directorDetail(@PathVariable Long id, Model model) {
	    Map<String, Object> director = actorRepository.findActorDetail(id); // 배우/감독 동일 테이블
	    model.addAttribute("actor", director); // 재사용
	    return "actor/detail"; // 뷰는 동일하게 재사용 가능
	}


}
