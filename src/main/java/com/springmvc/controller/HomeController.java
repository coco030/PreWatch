package com.springmvc.controller;

import com.springmvc.domain.Member; // Member 클래스 임포트 추가
import com.springmvc.domain.movie; // movie 클래스 임포트 추가
import com.springmvc.service.movieService;
import com.springmvc.service.userCartService; // userCartService 임포트 추가 (찜 상태 확인용)

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.transaction.annotation.Transactional; // 트랜잭션 관리를 위해 추가

import java.util.List;

import javax.servlet.http.HttpSession; // HttpSession 임포트 추가


@Controller
public class HomeController {
    private static final Logger logger = LoggerFactory.getLogger(HomeController.class);

    @Autowired
    private movieService movieService; // 영화 데이터 가져오기 위해 주입

    @Autowired
    private userCartService userCartService; // 찜 상태 확인을 위해 주입

    public HomeController() {
        System.out.println("public HomeController 객체생성");
    }

    // ⭐ 루트 경로 '/' 요청을 처리하며, 메인 페이지 데이터를 제공합니다. ⭐
    @GetMapping("/")
    @Transactional(readOnly = true) // 데이터 조회만 하므로 readOnly 트랜잭션 설정
    public String home(Model model, HttpSession session) {
        logger.info("루트 경로 '/' 요청이 감지되었습니다. 메인 홈페이지 데이터를 불러옵니다.");

        // 1. 최근 등록된 영화 목록 가져오기 (상위 3개)
        List<movie> recentMovies = movieService.getRecentMovies(3);
        model.addAttribute("movies", recentMovies); // 'movies'는 main.jsp의 "최근 등록된 영화" 섹션에 바인딩

        // 2. PreWatch 추천 랭킹 영화 목록 가져오기 (like_count 기준 상위 5개)
        List<movie> recommendedMovies = movieService.getTop5RecommendedMovies();
        model.addAttribute("recommendedMovies", recommendedMovies); // 'recommendedMovies'는 main.jsp의 "추천 랭킹" 섹션에 바인딩

        // 3. 로그인된 회원의 찜 상태 반영 (movieController에서 가져온 로직)
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember != null && "MEMBER".equals(loginMember.getRole())) {
            logger.debug("메인 페이지 - 로그인된 일반 회원 ({})의 찜 상태 반영 시작.", loginMember.getId());
            // recentMovies와 recommendedMovies 모두에 찜 상태 반영
            for (movie movie : recentMovies) {
                boolean isMovieLikedByCurrentUser = userCartService.isMovieLiked(loginMember.getId(), movie.getId());
                movie.setIsLiked(isMovieLikedByCurrentUser);
                logger.debug("  - 최근 영화 ID: {}, 찜 상태: {}", movie.getId(), isMovieLikedByCurrentUser);
            }
            for (movie movie : recommendedMovies) {
                boolean isMovieLikedByCurrentUser = userCartService.isMovieLiked(loginMember.getId(), movie.getId());
                movie.setIsLiked(isMovieLikedByCurrentUser);
                logger.debug("  - 추천 영화 ID: {}, 찜 상태: {}", movie.getId(), isMovieLikedByCurrentUser);
            }
            logger.debug("메인 페이지 - 로그인된 일반 회원 ({})의 찜 상태 반영 완료.", loginMember.getId());
        } else {
            logger.debug("메인 페이지 - 비로그인 또는 관리자 계정으로 찜 상태 미반영.");
        }

        model.addAttribute("userRole", session.getAttribute("userRole"));
        logger.debug("메인 홈페이지 데이터 로딩 완료.");
        // 여기서 "home"을 반환하면 /WEB-INF/views/home.jsp를 찾게 됩니다.
        // home.jsp에서 main.jsp를 include하고 있다면 그 구조를 유지합니다.
        return "home"; // home.jsp 반환
    }
}