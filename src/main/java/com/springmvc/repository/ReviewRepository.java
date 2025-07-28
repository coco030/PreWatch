package com.springmvc.repository;

import com.springmvc.domain.RecentCommentDTO;
import java.util.List;

public interface ReviewRepository {
 List<RecentCommentDTO> findTop3RecentComments();
}