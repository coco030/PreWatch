package com.springmvc.repository;

import com.springmvc.domain.RecentCommentDTO;
import java.util.List;
//(8/5 추가 그냥 전체 복붙하면 될듯요)
public interface ReviewRepository {
 List<RecentCommentDTO> findTop3RecentComments();
//모든 최근 댓글 조회 (페이징, 정렬, 검색 포함)
 List<RecentCommentDTO> findAllRecentCommentsWithDetails(int offset, int limit, String sortBy, String sortDirection, String searchType, String keyword);

 // 전체 댓글 수 조회 (페이징 계산용)
 int countAllComments(String searchType, String keyword);
}