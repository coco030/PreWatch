package com.springmvc.service;

import java.util.List;
import com.springmvc.domain.MovieImage;

public interface MovieImageService {
    List<MovieImage> getImagesForMovie(Long movieId, String apiId);
}
