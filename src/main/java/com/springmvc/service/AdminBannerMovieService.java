package com.springmvc.service;

import com.springmvc.domain.movie;
import com.springmvc.domain.AdminBannerMovie;
import com.springmvc.repository.AdminBannerMovieRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;

@Service
@Transactional
public class AdminBannerMovieService {

    private static final Logger logger = LoggerFactory.getLogger(AdminBannerMovieService.class);

    private final AdminBannerMovieRepository adminBannerMovieRepository;
    private final movieService movieService; // movie 상세 정보를 가져오기 위함

    @Autowired
    public AdminBannerMovieService(AdminBannerMovieRepository adminBannerMovieRepository, movieService movieService) {
        this.adminBannerMovieRepository = adminBannerMovieRepository;
        this.movieService = movieService;
    }

    /**
     * 관리자 배너에 표시될 영화 목록을 조회합니다.
     * @return movie 객체 리스트
     */
    @Transactional(readOnly = true)
    public List<movie> getAdminRecommendedMovies() {
        logger.debug("AdminBannerMovieService.getAdminRecommendedMovies() 호출.");
        List<AdminBannerMovie> bannerEntries = adminBannerMovieRepository.findAllOrdered();
        // ⭐ 디버그 로깅 추가: DB에서 가져온 배너 엔트리 확인 (7-24 오후12:41 추가 된 코드)
        logger.debug("DB에서 조회된 AdminBannerMovie 엔트리 수: {}", bannerEntries.size()); // (7-24 오후12:41 추가 된 코드)
        bannerEntries.forEach(entry -> logger.debug("  - 배너 엔트리 ID: {}, Movie ID: {}, Display Order: {}", entry.getId(), entry.getMovieId(), entry.getDisplayOrder())); // (7-24 오후12:41 추가 된 코드)

        List<movie> recommendedMovies = new ArrayList<>();

        for (AdminBannerMovie entry : bannerEntries) {
            movie movieDetail = movieService.findById(entry.getMovieId()); // movieService를 통해 상세 정보 조회
            // ⭐ 디버그 로깅 추가: 각 영화 ID에 대한 상세 정보 조회 결과 확인 (7-24 오후12:41 추가 된 코드)
            if (movieDetail != null) { // (7-24 오후12:41 추가 된 코드)
                logger.debug("  - Movie ID {}에 대한 상세 정보 조회 성공: {}", entry.getMovieId(), movieDetail.getTitle()); // (7-24 오후12:41 추가 된 코드)
                recommendedMovies.add(movieDetail);
            } else { // (7-24 오후12:41 추가 된 코드)
                logger.warn("  - Movie ID {}에 해당하는 영화 상세 정보를 찾을 수 없습니다. 배너 목록에서 제외됩니다.", entry.getMovieId()); // (7-24 오후12:41 추가 된 코드)
            } // (7-24 오후12:41 추가 된 코드)
        }
        logger.info("관리자 배너 영화 {}개 조회 완료.", recommendedMovies.size());
        return recommendedMovies;
    }

    /**
     * 영화를 관리자 배너에 추가합니다.
     * @param movieId 추가할 영화의 ID
     */
    public void addAdminRecommendedMovie(Long movieId) {
        logger.debug("AdminBannerMovieService.addAdminRecommendedMovie({}) 호출.", movieId);
        if (adminBannerMovieRepository.findByMovieId(movieId) == null) { // 이미 추가되었는지 확인
            adminBannerMovieRepository.addMovie(movieId);
            logger.info("영화 ID {}가 관리자 배너에 추가되었습니다.", movieId);
        } else {
            logger.warn("영화 ID {}는 이미 관리자 배너에 등록되어 있습니다.", movieId);
            throw new IllegalStateException("이미 등록된 영화입니다.");
        }
    }

    /**
     * 영화를 관리자 배너에서 제거합니다.
     * @param movieId 제거할 영화의 ID
     */
    public void removeAdminRecommendedMovie(Long movieId) {
        logger.debug("AdminBannerMovieService.removeAdminRecommendedMovie({}) 호출.", movieId);
        adminBannerMovieRepository.removeMovie(movieId);
        logger.info("영화 ID {}가 관리자 배너에서 제거되었습니다.", movieId);
    }

    /**
     * 특정 영화가 이미 관리자 배너에 등록되어 있는지 확인합니다.
     * @param movieId 확인할 영화의 ID
     * @return 등록되어 있으면 true, 아니면 false
     */
    @Transactional(readOnly = true)
    public boolean isMovieInAdminBanner(Long movieId) {
        return adminBannerMovieRepository.findByMovieId(movieId) != null;
    }
}
