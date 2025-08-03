<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %> 
<%System.out.println("영화 상세페이지 진입"); %>
<html>
<head>
    <meta charset="UTF-8">
    <title>PreWatch: 상세</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
</head> 
<body>
<jsp:include page="/WEB-INF/views/layout/header.jsp" />

<%-- 폭력성 주의문구 --%>
<c:import url="/review/sensitivity">
    <c:param name="movieId" value="${movie.id}" />
</c:import>   


<c:if test="${not empty recommended}">
    <div class="recommended-box">
        <p>
            <c:choose>
                <c:when test="${empty sessionScope.loginMember}">
                    이 영화와 비슷한 영화를 추천해드릴게요. 평가를 해주시면 취향에 맞는 비슷한 영화를 추천드릴 수 있습니다.
                </c:when>
                <c:otherwise>
                    ${sessionScope.loginMember.id}님의 취향에 맞는 영화를 추천해드릴게요
                </c:otherwise>
            </c:choose>
        </p>
			<ul>
            <c:forEach var="rec" items="${recommended}">
		    		<li>
				        <!-- 추천 영화 제목과 포스터 -->
				   		 <a href="${pageContext.request.contextPath}/movies/${rec.movieId}">
				            <div class="flex-shrink-0">
				                <c:choose>
				                    <c:when test="${not empty rec.posterPath and fn:startsWith(rec.posterPath, 'http')}">
		                    <img src="${rec.posterPath}" width="70" class="rounded shadow-sm"/>
				                    </c:when>
				                    <c:when test="${not empty rec.posterPath}">
				                        <img src="https://image.tmdb.org/t/p/w185/${rec.posterPath}" width="70" class="rounded shadow-sm"/>
				                    </c:when>
				                    <c:otherwise>
				                        <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" width="70" class="rounded shadow-sm"/>
				                    </c:otherwise> 
				                </c:choose>
				            </div>
				            ${rec.title} (관람등급: ${rec.rated})
				            
				            <!-- 장르 출력 -->
				            <!-- 장르 출력 -->
			                <div>장르: 
			                    <c:forEach var="genre" items="${rec.genres}">
			                        ${genre}
			                    </c:forEach>
			                </div>
				             <!-- 장르 출력 -->
				      </a>
				    </li>
				</c:forEach>
		        </ul>
		    </div>
		</c:if>






<div class="container mt-4">
<div class="row g-4 align-items-start">
  <!-- 왼쪽: 포스터 + 찜 버튼 -->
  <div class="col-md-4 text-center">

      <c:choose>
        <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
          <c:set var="posterSrc">
            <c:choose>
              <c:when test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                ${movie.posterPath}
              </c:when>
              <c:otherwise>
                ${pageContext.request.contextPath}${movie.posterPath}
              </c:otherwise>
            </c:choose>
          </c:set>
          <img src="${posterSrc}" alt="${movie.title} 포스터" class="img-fluid rounded shadow-sm" />
        </c:when>
        <c:otherwise>
          <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>" alt="기본 이미지" width="80" />
        </c:otherwise>
      </c:choose>
      
      
      <p><i class="fas fa-star text-warning me-1"></i><strong>평균 만족도 지수:</strong> 
        <c:choose>
          <c:when test="${movie.rating == 0.0}">N/A</c:when>
          <c:otherwise><fmt:formatNumber value="${movie.rating}" pattern="#0.0" /></c:otherwise>
        </c:choose> / 10.0
      </p>

      <p><i class="bi-exclamation-triangle-fill text-danger me-1"></i><strong>평균 폭력성 지수:</strong> 
        <c:choose>
          <c:when test="${movie.violence_score_avg == 0.0}">N/A</c:when>
          <c:otherwise><fmt:formatNumber value="${movie.violence_score_avg}" pattern="#0.0" /></c:otherwise>
        </c:choose> / 10.0
      </p>

      <p><i class="bi-emoji-dizzy-fill text-secondary me-1"></i><strong>평균 공포 지수:</strong> 
        <c:choose>
          <c:when test="${avgHorrorScore == 0}">N/A</c:when>
          <c:otherwise><fmt:formatNumber value="${avgHorrorScore}" pattern="#0.0" /></c:otherwise>
        </c:choose> / 10.0
      </p>

      <p><i class="bi-eye-fill text-warning me-1"></i><strong>평균 선정성 지수:</strong> 
        <c:choose>
          <c:when test="${avgSexualScore == 0}">N/A</c:when>
          <c:otherwise><fmt:formatNumber value="${avgSexualScore}" pattern="#0.0" /></c:otherwise>
        </c:choose> / 10.0
      </p>
      

      <!-- 찜 버튼 -->
      <div class="mt-3 favorite-button-wrapper">
        <c:if test="${empty movie.id}">
          <button class="favorite-button disabled" disabled>찜 기능 사용 불가 (DB에 없는 영화)</button>
          <span class="like-count-detail">총 0명 찜</span>
        </c:if>
        <c:if test="${not empty sessionScope.loginMember && sessionScope.userRole == 'MEMBER' && not empty movie.id}">
          <button class="favorite-button" id="toggleFavoriteBtn"
                  data-movie-id="${movie.id}"
                  data-is-liked="${movie.isLiked()}">
            <c:choose>
              <c:when test="${movie.isLiked()}">찜 목록에서 제거</c:when>
              <c:otherwise>찜 목록에 추가</c:otherwise>
            </c:choose>
          </button>
          <span class="like-count-detail" id="likeCountDetail">총 ${movie.likeCount}명 찜</span>
        </c:if>
        <c:if test="${empty sessionScope.loginMember || sessionScope.userRole == 'ADMIN'}">
          <button class="favorite-button disabled" disabled>
            <c:choose>
              <c:when test="${empty sessionScope.loginMember}">로그인 후 찜 가능</c:when>
              <c:otherwise>관리자 계정은 찜 기능 불가</c:otherwise>
            </c:choose>
          </button>
          <span class="like-count-detail">총 ${movie.likeCount}명 찜</span>
        </c:if>
      </div>
    </div>

    
  <!-- 중앙 + 오른쪽: 영화 정보 + 점수 입력란 통합 -->
  <div class="col-md-8">
    <!-- 영화 기본 정보 -->
    <h2 class="mb-3">${movie.title}</h2>
    <p><strong>감독:</strong> ${movie.director}</p>
    <p><strong>연도:</strong> ${movie.year}</p>
    <p><strong>장르:</strong> ${movie.genre}</p>
    <p><strong>연령 등급:</strong>
      <c:choose>
        <c:when test="${not empty movie.rated and movie.rated ne 'N/A'}">${movie.rated}</c:when>
        <c:otherwise>정보 없음</c:otherwise>
      </c:choose>
    </p>
    <p><strong>상영 시간:</strong>
      <c:choose>
        <c:when test="${not empty movie.runtime and movie.runtime ne 'N/A'}">${movie.runtime}</c:when>
        <c:otherwise>정보 없음</c:otherwise>
      </c:choose>
    </p>
    <p><strong>개봉일:</strong>
      <c:choose>
        <c:when test="${not empty movie.releaseDate and movie.releaseDate ne 'N/A'}">${movie.releaseDate}</c:when>
        <c:otherwise>정보 없음</c:otherwise>
      </c:choose>
    </p>

    <!-- 점수 입력 모듈 (기존 col-md-3 내부 내용) -->
    <div class="d-flex flex-column gap-2 my-3" style="font-size: 0.92rem;">
      <!-- 1. 만족도 -->
      <div class="d-flex align-items-center">
        <div class="me-3" style="min-width: 80px;"><i class="fas fa-star text-warning me-1" style="font-size: 0.9em;"></i><strong>만족도</strong></div>
        <div style="transform: scale(0.85); transform-origin: left;">
          <c:import url="/review/rating">
            <c:param name="movieId" value="${movie.id}" />
          </c:import>
        </div>
      </div>

      <!-- 2. 폭력성 -->
      <div class="d-flex align-items-center">
        <div class="me-3" style="min-width: 80px;"><i class="bi-exclamation-triangle-fill text-danger me-1" style="font-size: 0.9em;"></i><strong>폭력성</strong></div>
        <div style="transform: scale(0.85); transform-origin: left;">
          <c:import url="/review/violence">
            <c:param name="movieId" value="${movie.id}" />
          </c:import>
        </div>
      </div>

      <!-- 3. 공포 -->
      <div class="d-flex align-items-center">
        <div class="me-3" style="min-width: 80px;"><i class="bi-emoji-dizzy-fill text-secondary me-1" style="font-size: 0.9em;"></i><strong>공포</strong></div>
        <div style="transform: scale(0.85); transform-origin: left;">
          <c:import url="/review/HorrorScoreUserView">
            <c:param name="movieId" value="${movie.id}" />
          </c:import>
        </div>
      </div>

      <!-- 4. 선정성 -->
      <div class="d-flex align-items-center">
        <div class="me-3" style="min-width: 80px;"><i class="bi-eye-fill text-warning me-1" style="font-size: 0.9em;"></i><strong>선정성</strong></div>
        <div style="transform: scale(0.85); transform-origin: left;">
          <c:import url="/review/SexualScoreUserView">
            <c:param name="movieId" value="${movie.id}" />
          </c:import>
        </div>
      </div>
    </div>

    <!-- 개요 + 태그 -->
    <div class="row">
      <div class="col-12">
        <p><strong>개요:</strong></p>
        <p class="text-muted" style="line-height: 1.6;">${movie.overview}</p>
      </div>
    </div>
   
    <div class="bg-body-bg rounded-3 p-3">
      <c:import url="/review/reviewTagAll">
        <c:param name="movieId" value="${movie.id}" />
      </c:import>
    </div>
  </div> <!-- 중앙 col-8 끝 -->
</div> <!-- row 끝 -->

<!-- 통계 메시지 -->
<c:if test="${not empty insights}">
  <div class="container mt-4">
    <div class="card border-0" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
      <div class="card-body text-white">
        <h6 class="card-title mb-3">
          <i class="fas fa-lightbulb me-2"></i>영화 인사이트
        </h6>
        <div class="insights-list">
          <c:forEach var="insight" items="${insights}">
            <div class="d-flex align-items-start mb-2">
              <i class="fas fa-quote-left me-2 mt-1" style="font-size: 0.8em; opacity: 0.7;"></i>
              <span style="line-height: 1.5;">${insight.message}</span>
            </div>
          </c:forEach>
        </div>
      </div>
    </div>
  </div>
</c:if>

</div> <!-- container mt-4 끝 -->

<!-- 출연자 정보가 하나도 없을 땐 조건문으로 감싸서 안 이 섹션을 안 보이게-->
<c:if test="${not empty dbCastList or not empty castAndCrew}">
<div class="container mt-4">
<!-- 주요 참여진 박스 전체를 카드로 감싸기 -->
<div class="card bg mb-4" style="border:none;">
  <div class="card-body">
    <h5 class="mb-2">출연/제작</h5>
    <ul class="list-unstyled d-flex flex-wrap gap-3" style="margin-top:8px; padding-left:0;">

		  <!-- 1. DB(저장된) 출연진 리스트: 감독 먼저, 그 다음 배우/성우/기타 -->
		  <c:if test="${not empty dbCastList}">
		    <!-- 1-1. 감독 먼저 -->
		    <c:forEach var="person" items="${dbCastList}">
		      <c:if test="${person.role_type eq 'DIRECTOR'}">
		        <li style="width:128px; text-align:center;">
		          <a href="${pageContext.request.contextPath}/directors/${person.id}" style="text-decoration:none; color:inherit;">
		            <!-- 동그라미 프로필 -->
		            <c:choose>
		              <c:when test="${not empty person.profile_image_url}">
		                <img src="https://image.tmdb.org/t/p/w185/${person.profile_image_url}"
		                     class="rounded-circle border mb-2"
		                     style="width:90px; height:90px; object-fit:cover; background:#f8f9fa;" />
		              </c:when>
		              <c:otherwise>
		                <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>"
		                     class="rounded-circle border mb-2"
		                     style="width:90px; height:90px; object-fit:cover; background:#f8f9fa;" />
		              </c:otherwise>
		            </c:choose>
		            <!-- 라벨(감독) -->
		            <div>
		              <span class="badge bg-primary">감독</span>
		            </div>
		            <!-- 이름 -->
		            <div class="fw-bold text-truncate" style="margin:4px 0 0 0; min-height:22px;" title="${person.name}">
		              ${person.name}
		            </div>
		            <!-- 역할명 -->
		            <div style="color:#888; font-size:0.93em;">
		              <c:if test="${not empty person.role_name}">${person.role_name}</c:if>
		            </div>
		          </a>
		        </li>
		      </c:if>
		    </c:forEach>
		    <!-- 1-2. 배우/성우/기타 -->
		    <c:forEach var="person" items="${dbCastList}">
		      <c:if test="${person.role_type ne 'DIRECTOR'}">
		        <li style="width:128px; text-align:center;">
		          <a href="${pageContext.request.contextPath}/actors/${person.id}" style="text-decoration:none; color:inherit;">
		            <c:choose>
		              <c:when test="${not empty person.profile_image_url}">
		                <img src="https://image.tmdb.org/t/p/w185/${person.profile_image_url}"
		                     class="rounded-circle border mb-2"
		                     style="width:90px; height:90px; object-fit:cover; background:#f8f9fa;" />
		              </c:when>
		              <c:otherwise>
		                <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>"
		                     class="rounded-circle border mb-2"
		                     style="width:90px; height:90px; object-fit:cover; background:#f8f9fa;" />
		              </c:otherwise>
		            </c:choose>
		            <!-- 라벨(배우/성우/기타) -->
		            <div>
		              <c:choose>
		                <c:when test="${person.role_type eq 'ACTOR'}">
		                  <span class="badge bg-secondary">배우</span>
		                </c:when>
		                <c:when test="${person.role_type eq 'VOICE'}">
		                  <span class="badge bg-success">성우</span>
		                </c:when>
		                <c:otherwise>
		                  <span class="badge bg-light text-dark">${person.role_type}</span>
		                </c:otherwise>
		              </c:choose>
		            </div>
		            <!-- 이름 -->
		            <div class="fw-bold text-truncate" style="margin:4px 0 0 0; min-height:22px;" title="${person.name}">
		              ${person.name}
		            </div>
		            <!-- 역할명 -->
		            <div style="color:#888; font-size:0.93em;">
		              <c:if test="${not empty person.role_name}">${person.role_name}</c:if>
		            </div>
		          </a>
		        </li>
		      </c:if>
		    </c:forEach>
		  </c:if>

  <!-- 2. TMDB 실시간 출연진 (dbCastList가 비어있을 때만) -->
<c:if test="${empty dbCastList && not empty castAndCrew}">
    
    <!-- 1. 감독 먼저 출력 -->
    <c:forEach var="person" items="${castAndCrew}">
      <c:if test="${person.type eq 'DIRECTOR'}">
        <li style="width:128px; text-align:center;">
          <a style="text-decoration:none; color:inherit;">
            <!-- 프로필 이미지 -->
            <c:choose>
              <c:when test="${not empty person.profile_path}">
                <img src="https://image.tmdb.org/t/p/w185/${person.profile_path}"
                     class="rounded-circle border mb-2"
                     style="width:90px; height:90px; object-fit:cover; background:#f8f9fa;" />
              </c:when>
              <c:otherwise>
                <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>"
                     class="rounded-circle border mb-2"
                     style="width:90px; height:90px; object-fit:cover; background:#f8f9fa;" />
              </c:otherwise>
            </c:choose>

            <!-- 배지 -->
            <div><span class="badge bg-primary">감독</span></div>

            <!-- 이름 -->
            <div class="fw-bold text-truncate" style="margin:4px 0 0 0; min-height:22px;" title="${person.name}">
              ${person.name}
            </div>

            <!-- 역할명 (없을 수도 있음) -->
            <div style="color:#888; font-size:0.93em;">
              <c:if test="${not empty person.role}">${person.role}</c:if>
            </div>
          </a>
        </li>
      </c:if>
    </c:forEach>

    <!-- 2. 배우/성우/기타 출력 -->
    <c:forEach var="person" items="${castAndCrew}">
      <c:if test="${person.type ne 'DIRECTOR'}">
        <li style="width:128px; text-align:center;">
          <a style="text-decoration:none; color:inherit;">
            <!-- 프로필 이미지 -->
            <c:choose>
              <c:when test="${not empty person.profile_path}">
                <img src="https://image.tmdb.org/t/p/w185/${person.profile_path}"
                     class="rounded-circle border mb-2"
                     style="width:90px; height:90px; object-fit:cover; background:#f8f9fa;" />
              </c:when>
              <c:otherwise>
                <img src="<c:url value='/resources/images/movies/256px-No-Image-Placeholder.png'/>"
                     class="rounded-circle border mb-2"
                     style="width:90px; height:90px; object-fit:cover; background:#f8f9fa;" />
              </c:otherwise>
            </c:choose>

            <!-- 배지 -->
            <div>
              <c:choose>
                <c:when test="${person.type eq 'ACTOR'}">
                  <span class="badge bg-secondary">배우</span>
                </c:when>
                <c:when test="${person.type eq 'VOICE'}">
                  <span class="badge bg-success">성우</span>
                </c:when>
                <c:otherwise>
                  <span class="badge bg-light text-dark">${person.type}</span>
                </c:otherwise>
              </c:choose>
            </div>

            <!-- 이름 -->
            <div class="fw-bold text-truncate" style="margin:4px 0 0 0; min-height:22px;" title="${person.name}">
              ${person.name}
            </div>

            <!-- 역할명 -->
            <div style="color:#888; font-size:0.93em;">
              <c:if test="${not empty person.role}">${person.role}</c:if>
            </div>
          </a>
        </li>
      </c:if>
    </c:forEach>
</c:if>
      </ul>
  </div>
</div>
</div>
</c:if>


	<!-- 리뷰 작성 -->
	<div class="container mt-3">
	  <div class="bg-body-bg rounded-3 p-3">
	    <c:import url="/review/content">
	      <c:param name="movieId" value="${movie.id}" />
	    </c:import>
	  </div>
	</div>
	
	<!-- 태그 작성 -->
	<c:if test="${not empty sessionScope.loginMember}">
	<div class="container mt-3">
	  <div class="bg-body-bg rounded-3 p-3">
	            <c:import url="/review/tag">
	                <c:param name="movieId" value="${movie.id}" />
	            </c:import>
	 </div>
	</div>
	</c:if>

<!-- 다른 유저의 리뷰 리스트 -->
<c:if test="${not empty reviewList}">
	<div class="container mt-4 mb-5">
	    <div class="p-3">
	        <h5 class="fw-bold mb-3">
	            <i class="fas fa-comments text-primary me-1"></i>코멘트
	        </h5>
	       <jsp:include page="/WEB-INF/views/reviewModule/reviewList.jsp">
			    <jsp:param name="movieId" value="${movie.id}" />
			</jsp:include>
	    </div>
	</div>
</c:if>

<div class="container mt-4 mb-5">
  <c:if test="${not empty movieImages}">
    <div class="gallery-section mt-4">
      <h4>스틸컷</h4>
      <div class="row g-2">
        <c:forEach var="img" items="${movieImages}" varStatus="status">
          <div class="col-6 col-md-4 ${status.index >= 6 ? 'd-none more-gallery' : ''}">
            <img src="https://image.tmdb.org/t/p/w500${img.imageUrl}"
                 alt="스틸컷"
                 class="img-fluid rounded shadow-sm"
                 style="cursor:pointer"
                 data-bs-toggle="modal"
                 data-bs-target="#imageModal"
                 data-bs-image="https://image.tmdb.org/t/p/original${img.imageUrl}">
          </div>
        </c:forEach>
      </div>

      <!-- 6장 넘는 경우에만 '더 보기' 버튼 출력 -->
      <c:if test="${movieImages.size() > 6}">
        <div class="mt-2 text-center">
          <button id="toggleGalleryBtn" class="btn btn-outline-secondary btn-sm">더 보기</button>
        </div>
      </c:if>
    </div>
  </c:if>
</div>

<!-- 모바일 하단 고정 메뉴에 가려지는 공간 확보용 여백 -->
<div class="d-block d-md-none" style="height: 80px;"></div>

<!-- 더보기 모달창 -->
<div class="modal fade" id="imageModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-xl modal-fullscreen-sm-down">
    <div class="modal-content position-relative bg-transparent border-0">
      
      <!-- 닫기 버튼 (오른쪽 상단에 고정) -->
      <button type="button" class="btn-close position-absolute top-0 end-0 m-3"
              data-bs-dismiss="modal" aria-label="Close"
              style="filter: brightness(0.7); background-color: rgba(255,255,255,0.6);">
      </button>

      <!-- 이미지 자체: 가운데 정렬, 최대크기 조절 -->
      <img id="modalImage"
           src=""
           class="img-fluid rounded d-block mx-auto"
           style="max-height: 95vh; object-fit: contain;">
    </div>
  </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<jsp:include page="/WEB-INF/views/layout/footer.jsp" />
<script>
    $(document).ready(function() {
        $(document).off('click', '#toggleFavoriteBtn').on('click', '#toggleFavoriteBtn', function() {
            const movieId = $(this).data('movie-id');
            const button = $(this);
            const likeCountDetailSpan = $('#likeCountDetail');

            if (button.hasClass('processing')) return;

            button.addClass('processing').prop('disabled', true);

            $.ajax({
                url: '${pageContext.request.contextPath}/movies/' + movieId + '/toggleCart',
                type: 'POST',
                success: function(response) {
                    if (response.status === 'added') {
                        button.text('찜 목록에서 제거');
                        button.data('is-liked', true);
                        alert("찜 목록에 추가되었습니다.");
                    } else if (response.status === 'removed') {
                        button.text('찜 목록에 추가');
                        button.data('is-liked', false);
                        alert("찜 목록에서 제거되었습니다.");
                    }
                    if (response.newLikeCount !== undefined) {
                        likeCountDetailSpan.text(`총 ${response.newLikeCount}명 찜`);
                    }
                },
                error: function(xhr) {
                    alert("찜 처리 중 오류가 발생했습니다: " + xhr.responseText);
                },
                complete: function() {
                    button.removeClass('processing');
                    if (button.data('is-liked') !== undefined) {
                        button.prop('disabled', false);
                    }
                }
            });
        });
        // 스틸컷 '더 보기' 처리
        $('#toggleGalleryBtn').on('click', function() {
            const hiddenImages = $('.more-gallery');
            const isHidden = hiddenImages.first().hasClass('d-none');

            hiddenImages.toggleClass('d-none');
            $(this).text(isHidden ? '간단히 보기' : '더 보기');
        });
        
        // 스틸컷 이미지 클릭 시 모달에 크게 보여주기
        $('[data-bs-toggle="modal"]').on('click', function() {
            const imgSrc = $(this).data('bs-image');
            $('#modalImage').attr('src', imgSrc);
        });
    });
</script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js"></script>
</body>
</html>