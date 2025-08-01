<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% System.out.println("mypage 뷰 진입"); %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>PreWatch: 마이페이지</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
<style>
    /* 카드 전체에 hover 시 부드럽게 어두워짐 */
    a.text-decoration-none.text-dark:hover .card {
        background-color: rgba(0, 0, 0, 0.05); /* 아주 약한 회색 톤 */
        transition: background-color 0.2s ease;
    }
    /* 포스터 여백 */
	.poster-img {
	    margin: 12px;
	    border-radius: 8px;
	}
</style>
</head>
<body class="bg-white">

<!-- 헤더 -->
<jsp:include page="/WEB-INF/views/layout/header.jsp" />

<div class="container pt-2 mt-2">
	<div class="bg-light p-3 rounded d-flex align-items-center mb-3">
	  <i class="fas fa-film me-2 text-secondary"></i>
	  <strong class="text-dark">${sessionScope.loginMember.id}님의 영화 기록</strong>
	   <a href="<c:url value='/member/mypage_taste'/>" class="btn btn-primary">
            📊 나의 취향 분석 리포트 보기
        </a>
	</div>

    <c:forEach var="review" items="${myReviews}">
        <c:set var="movie" value="${movieMap[review.movieId]}" />

        <a href="${pageContext.request.contextPath}/movies/${movie.id}" class="text-decoration-none text-dark">
            <div class="card mb-4 shadow-sm">
                <div class="row g-0">
                    <div class="col-md-3 text-center">
					    <c:if test="${not empty movie.posterPath}">
					        <img src="${movie.posterPath}" class="img-fluid mx-auto d-block poster-img" alt="포스터" />
					    </c:if>
					</div>
                    <div class="col-md-9">
                        <div class="card-body">
                            <h5 class="card-title">${movie.title}</h5>
                            <p class="card-text mb-1">
						    <strong>만족도:</strong>
						    <c:choose>
						        <c:when test="${review.userRating == 0}">(아직 평가를 하지 않으셨어요)</c:when>
						        <c:otherwise>${review.userRating}점</c:otherwise>
						    </c:choose>
						</p>
						
						<p class="card-text mb-1">
						    <strong>폭력성:</strong>
						    <c:choose>
						        <c:when test="${review.violenceScore == 0}">(아직 평가를 하지 않으셨어요)</c:when>
						        <c:otherwise>${review.violenceScore}점</c:otherwise>
						    </c:choose>
						</p>
						
					<p class="card-text mb-1">
					    <strong>공포성:</strong>
					    <c:choose>
					        <c:when test="${review.horrorScore == null}">(아직 평가를 하지 않으셨어요)</c:when>
					        <c:otherwise>${review.horrorScore}점</c:otherwise>
					    </c:choose>
					</p>
					
					<p class="card-text mb-1">
					    <strong>선정성:</strong>
					    <c:choose>
					        <c:when test="${review.sexualScore == null}">(아직 평가를 하지 않으셨어요)</c:when>
					        <c:otherwise>${review.sexualScore}점</c:otherwise>
					    </c:choose>
					</p>

                            
                            <p class="card-text mb-1">
							
							<fmt:parseDate value="${review.createdAt}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="writtenDate" />
							
							<p class="card-text mb-1">
							   
							    <c:choose>
							        <c:when test="${empty review.reviewContent}">
							            (아직 리뷰 작성을 하지 않으셨어요)
							        </c:when>
							        <c:otherwise>
							            ${review.reviewContent}<br>
							            <span class="badge bg-light text-dark" style="font-size: 0.95em;">
							                <fmt:formatDate value="${writtenDate}" pattern="yyyy.MM.dd HH:mm" />
							            </span>
							        </c:otherwise>
							    </c:choose>
							</p>
                            <p class="card-text">
                             
                                <c:choose>
                                    <c:when test="${empty review.tags}">(아직 태그 작성을 하지 않으셨어요)</c:when>
                                    <c:otherwise>${review.tags}</c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </a>
    </c:forEach>

    <!-- 페이지네이션 -->
    <nav aria-label="리뷰 페이지 이동">
        <ul class="pagination justify-content-center">
            <li class="page-item <c:if test='${currentPage == 1}'>disabled</c:if>">
                <a class="page-link" href="?page=${currentPage - 1}">이전</a>
            </li>

            <c:forEach var="i" begin="1" end="${totalPages}">
                <li class="page-item <c:if test='${i == currentPage}'>active</c:if>">
                    <a class="page-link" href="?page=${i}">${i}</a>
                </li>
            </c:forEach>

            <li class="page-item <c:if test='${currentPage == totalPages}'>disabled</c:if>">
                <a class="page-link" href="?page=${currentPage + 1}">다음</a>
            </li>
        </ul>
    </nav>
</div>
<!-- 모바일 하단 고정 메뉴에 가려지는 공간 확보용 여백 -->
<div class="d-block d-md-none" style="height: 80px;"></div>
<!-- 푸터 -->
<jsp:include page="/WEB-INF/views/layout/footer.jsp" />
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

</body>
</html>