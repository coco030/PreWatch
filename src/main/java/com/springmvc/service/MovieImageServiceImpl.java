package com.springmvc.service;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.springmvc.domain.MovieImage;
import com.springmvc.repository.MovieImageRepository;

@Service
public class MovieImageServiceImpl implements MovieImageService {

    @Autowired
    private MovieImageRepository movieImageRepository;

    @Autowired
    private TmdbApiService tmdbApiService;

    @Override
    public List<MovieImage> getImagesForMovie(Long movieId, String apiId) {
        // 1. 저장된 영화인 경우 DB 조회 시도
        if (movieId != null) {
            List<MovieImage> dbImages = movieImageRepository.findImagesByMovieId(movieId);
            if (!dbImages.isEmpty()) {
                return dbImages;
            }
            // dbImages가 비어 있으면 fallback
        }

        // 2. 실시간 TMDb 조회
        List<String> urls = tmdbApiService.getBackdropImageUrls(apiId);
        List<MovieImage> results = new ArrayList<>();
        int order = 0;
        for (String url : urls) {
            results.add(new MovieImage(null, url, "backdrop", order++));
        }
        return results;
    }

}
