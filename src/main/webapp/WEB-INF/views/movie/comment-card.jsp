<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
 <link rel="stylesheet" href="<c:url value='/resources/css/comment-card'/>">


    
      <h2 class="section-title">최근 달린 댓글</h2>
	<div class="row g-3 justify-content-center">
	  <c:choose>
	    <c:when test="${not empty recentComments}">
	      <c:forEach var="review" items="${recentComments}">
	        <c:set var="movie" value="${movieMap[review.movieId]}" />
	        <div class="col-12 col-md-6 col-lg-4">
	          <a href="${pageContext.request.contextPath}/movies/${movie.id}" class="text-decoration-none text-dark">
	            <div class="card h-100 shadow-sm border-0 p-3 d-flex flex-column comment-card">
	
	              <!-- 상단: 사용자명 + 별점 -->
	              <div class="d-flex align-items-center justify-content-between mb-2">
	                <div class="d-flex align-items-center">
	                  <span class="fw-semibold text-dark me-2">${review.memberId}</span>
	                  <span class="d-flex align-items-center small">
	                    <c:set var="userRating5Point" value="${review.userRating / 2.0}" />
	                    <c:set var="fullStars" value="${fn:split(userRating5Point, '.')[0]}" />
	                    <c:set var="hasHalfStar" value="${fn:length(fn:split(userRating5Point, '.')) > 1 and fn:split(userRating5Point, '.')[1] eq '5'}" />
	                    <c:forEach begin="1" end="${fullStars}">
	                      <i class="fas fa-star text-warning me-1"></i>
	                    </c:forEach>
	                    <c:if test="${hasHalfStar}">
	                      <i class="fas fa-star-half-alt text-warning me-1"></i>
	                    </c:if>
	                    <c:forEach begin="1" end="${5 - fullStars - (hasHalfStar ? 1 : 0)}">
	                      <i class="far fa-star text-muted me-1"></i>
	                    </c:forEach>
	                    <span class="text-muted ms-1">(<fmt:formatNumber value="${userRating5Point}" pattern="#0.0" /> / 5.0)</span>
	                  </span>
	                </div>
	              </div>
	
	              <!-- 중단: 포스터 + 영화 정보 -->
	              <div class="d-flex mb-3 flex-grow-1">
	                <img
	                  src="${review.posterPath != null && review.posterPath != '' ? review.posterPath : pageContext.request.contextPath.concat('/resources/images/movies/256px-No-Image-Placeholder.png')}"
	                  onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png';"
	                  alt="${review.movieName} 포스터"
	                  class="rounded me-3"
	                  style="width: 60px; height: 90px; object-fit: cover; flex-shrink: 0;"
	                />
	                <div class="flex-grow-1">
	                  <h5 class="fw-semibold text-dark mb-1">${review.movieName}</h5>
	                  <p class="text-muted small" style="display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; text-overflow: ellipsis;">
	                    ${review.reviewContent}
	                  </p>
	                </div>
	              </div>
	
	              <!-- 하단: 하트 -->
	              <div class="d-flex align-items-center mt-auto pt-2 border-top">
	                <i class="fas fa-heart text-danger me-2"></i>
	                <span class="small text-muted">찜 ${review.newLikeCount}</span>
	              </div>
	
	            </div>
	          </a>
	        </div>
	      </c:forEach>
	    </c:when>
	    <c:otherwise>
	      <div class="col-12">
	        <p class="text-center text-muted">아직 등록된 코멘트가 없습니다.</p>
	      </div>
	    </c:otherwise>
	  </c:choose>
	</div>
</div>