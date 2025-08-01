package com.springmvc.repository;

import java.util.List;
import com.springmvc.domain.MovieImage;

public interface MovieImageRepository {
    List<MovieImage> findImagesByMovieId(Long movieId);
    void saveImages(List<MovieImage> images);
    void deleteImagesByMovieId(Long movieId); // 관리자용 등 추가 가능
}
