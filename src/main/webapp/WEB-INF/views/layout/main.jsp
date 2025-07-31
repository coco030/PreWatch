<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<body class="bg">
  <div class="container py-4">

   <!-- 최근 등록된 영화 -->
	<div class="d-flex justify-content-between align-items-center mb-3">
    <h2 class="section-title mb-0">최근 등록된 영화</h2>
    <a href="<c:url value='/movies/all-recent'/>" class="btn btn-primary btn-sm mt-4">더 보기</a>
	</div>
	
	<div class="row g-4 justify-content-center">
	  <c:forEach var="movie" items="${movies}" begin="0" end="2">
	    <div class="col-6 col-md-4 col-lg-4">
	      <div class="movie-card">
	        <div class="rank-badge">NEW</div>
	        <a href="<c:url value='/movies/${movie.id}'/>">
	          <c:set var="posterSrc">
	            <c:choose>
	              <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
	                <c:choose>
	                  <c:when test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
	                    ${movie.posterPath}
	                  </c:when>
	                  <c:otherwise>
	                    ${pageContext.request.contextPath}${movie.posterPath}
	                  </c:otherwise>
	                </c:choose>
	              </c:when>
	              <c:otherwise>
	                ${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png
	              </c:otherwise>
	            </c:choose>
	          </c:set>
	          <img src="${posterSrc}" alt="${movie.title} 포스터" />
	          <div class="p-3">
	            <h5 class="fw-bold">${movie.title}</h5>
	            <p class="text-muted mb-1">${movie.year} | ${movie.genre}</p>
	            <p class="text-muted mb-0">평점: <fmt:formatNumber value="${movie.rating}" pattern="#0.0" /></p>
	          </div>
	        </a>
	      </div>
	    </div>
	  </c:forEach>
	</div> <!-- // row div 닫힘 -->


    <!-- 배너 버튼 -->
    <div class="banner-section">
      <div class="d-flex flex-wrap justify-content-center">
        <a href="<c:url value='/recommend'/>" class="banner-button">추천</a>
        <a href="<c:url value='/calendar'/>" class="banner-button">캘린더</a>
        <a href="<c:url value='/event'/>" class="banner-button">이벤트</a>
        <c:choose>
          <c:when test="${not empty loginMember}">
            <a href="<c:url value='/review/myreviewSummary'/>" class="banner-button">나의 취향 분석</a>
          </c:when>
          <c:otherwise>
            <!-- id="iframeLoginModal"인 모달. -->
            <span class="banner-button" 
                  data-bs-toggle="modal" 
                  data-message="이 기능은 로그인 후 이용하실 수 있어요"
                  data-bs-target="#loginModal"
                  style="cursor: pointer;">
              나의 취향 분석
            </span>
          </c:otherwise>
        </c:choose>
      </div>
    </div>
	 <!-- 개봉 예정작 -->
    <div class="d-flex justify-content-between align-items-center mb-3">
      <h2 class="section-title mb-0">개봉 예정작</h2>
        <a href="<c:url value='/movies/all-upcoming'/>" class="btn btn-primary btn-sm mt-4">더 보기</a>
    </div>
    <div class="section-divider"></div> <jsp:include page="/WEB-INF/views/movie/upcomingMovies.jsp" />
	
	 <!-- 보고 싶어요 랭킹 -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2 class="section-title mb-0">PreWatch 추천 랭킹</h2>
        <a href="<c:url value='/movies/all-recommended'/>" class="btn btn-primary btn-sm mt-4">더 보기</a>
    </div>
    <div class="section-divider"></div> 
    <div class="row g-3 justify-content-center">
        <c:set var="rank" value="0" />
        <c:forEach var="movie" items="${recommendedMovies}">
            <c:set var="rank" value="${rank + 1}" />
            <div class="col-6 col-sm-4 col-md-3 col-lg-2">
                <div class="movie-card">
                    <div class="rank-badge">${rank}</div>
                    <a href="<c:url value='/movies/${movie.id}'/>">
                        <c:set var="posterSrc">
                            <c:choose>
                                <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                                    <c:choose>
                                        <c:when test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                                            ${movie.posterPath}
                                        </c:when>
                                        <c:otherwise>
                                            ${pageContext.request.contextPath}${movie.posterPath}
                                        </c:otherwise>
                                    </c:choose>
                                </c:when>
                                <c:otherwise>
                                    ${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png
                                </c:otherwise>
                            </c:choose>
                        </c:set>
                        <img src="${posterSrc}" alt="${movie.title} 포스터" />
                        <div class="p-2">
                            <h5 class="fw-semibold small">${movie.title}</h5>
                            <p class="text-muted small mb-1">${movie.year} | ${movie.genre}</p>
                            <p class="text-muted small mb-1">찜 : ${movie.likeCount}</p>
                        </div>
                    </a>
                </div>
            </div>
        </c:forEach>
    </div>

	 <!-- 관리자 추천 영화 -->
    <h2 class="section-title">PreWatch 추천 영화</h2>
    <div class="section-divider"></div> 
    <c:choose>
        <c:when test="${not empty adminRecommendedMovies}">
            <div class="row g-3 justify-content-center">
                <c:set var="rank" value="0" />
                <c:forEach var="movie" items="${adminRecommendedMovies}">
                    <c:set var="rank" value="${rank + 1}" />
                    <div class="col-6 col-sm-4 col-md-3 col-lg-2">
                        <div class="movie-card">
                            <div class="rank-badge">${rank}</div>
                            <a href="<c:url value='/movies/${movie.id}'/>">
                                <c:set var="posterSrc">
                                    <c:choose>
                                        <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                                            <c:choose>
                                                <c:when test="${fn:startsWith(movie.posterPath, 'http://') or fn:startsWith(movie.posterPath, 'https://')}">
                                                    ${movie.posterPath}
                                                </c:when>
                                                <c:otherwise>
                                                    ${pageContext.request.contextPath}${movie.posterPath}
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:otherwise>
                                            ${pageContext.request.contextPath}/resources/images/movies/256px-No-Image-Placeholder.png
                                        </c:otherwise>
                                    </c:choose>
                                </c:set>
                                <img src="${posterSrc}" alt="${movie.title} 포스터" />
                                <div class="p-2">
                                    <h5 class="fw-semibold small">${movie.title}</h5>
                                    <p class="text-muted small mb-1">${movie.year} | ${movie.genre}</p>
                                    <p class="text-muted small mb-1">찜 : ${movie.likeCount}</p>
                                </div>
                            </a>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:when>
        <c:otherwise>
            <div class="no-movie-box">
                아직 추천 영화가 없습니다.
            </div>
        </c:otherwise>
    </c:choose>
    
    <!-- 최근 코멘트-->

    <c:import url="/movies/commentCard" />
<div class="calendar-container">
        <div class="calendar-header">
            <div class="calendar-nav-left"> <button type="button" class="calendar-nav" onclick="changeMonth(${currentYear}, ${currentMonth - 1})">&lt; 이전 달</button>
            </div>

            <span id="currentMonthDisplay" class="calendar-month-display">${currentYear}년 ${currentMonth}월</span> <div class="calendar-nav-right"> <button type="button" class="calendar-nav" onclick="changeMonth(${currentYear}, ${currentMonth + 1})">다음 달 &gt;</button>
            </div>
        </div>

        <table class="calendar-table"><%-- 07-31 추가 --%>
            <thead>
                <tr>
                    <th>일</th><th>월</th><th>화</th><th>수</th><th>목</th><th>금</th><th>토</th>
                </tr>
            </thead>
            <tbody id="calendarBody">
                <c:forEach var="week" items="${calendarWeeks}">
                    <tr>
                        <c:forEach var="dayData" items="${week}">
                            <td class="${dayData.todayStatus ? 'today' : ''} ${!dayData.currentMonthStatus ? 'other-month' : ''}"> <span class="day-number">
                                    ${dayData.date.dayOfMonth} </span>
                                <div class="movie-poster-container">
                                    <c:set var="moviesOnThisDay" value="${dayData.movies}" />
                                    <c:if test="${not empty moviesOnThisDay}">
                                        <c:set var="posterCount" value="${fn:length(moviesOnThisDay)}" />
                                        <c:forEach var="movie" items="${moviesOnThisDay}">
                                            <a href="<c:url value='/movies/${movie.id}'/>">
                                                <img src="<c:url value='${movie.posterPath}'/>" alt="${movie.title} 포스터"
                                                     class="movie-poster
                                                        <c:if test="${posterCount == 2}">small</c:if>
                                                        <c:if test="${posterCount >= 3}">smaller</c:if>
                                                     ">
                                            </a>
                                        </c:forEach>
                                    </c:if>
                                </div>
                            </td>
                        </c:forEach>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div> <%-- .container py-4 닫는 태그 --%>

  <!-- ========== 로그인 모달 ========== -->
    <jsp:include page="/WEB-INF/views/loginModal.jsp" />
  <!-- Bootstrap JS -->
 <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
// 캘린더 데이터를 동적으로 업데이트하는 함수
function changeMonth(year, month) {
    // 월 계산 (1월 미만, 12월 초과 처리)
    if (month < 1) {
        year--;
        month = 12;
    } else if (month > 12) {
        year++;
        month = 1;
    }
    var contextPath = "${pageContext.request.contextPath}"; // 컨텍스트 패스
    
    $.ajax({
        url: contextPath + '/calendar/data', // 07-31: AJAX 엔드포인트
        type: 'GET',
        data: { year: year, month: month },
        dataType: 'json', // 서버 응답을 JSON으로 예상
        success: function(response) {
            console.log("AJAX Success:", response); // 디버깅용
            updateCalendarUI(response, contextPath); // 07-31: contextPath를 updateCalendarUI에 전달
        },
        error: function(xhr, status, error) {
            console.error("AJAX Error:", status, error, xhr.responseText);
            alert("달력 데이터를 불러오는 데 실패했습니다: " + error);
        }
    });
}
// 서버로부터 받은 데이터로 달력 UI를 업데이트하는 함수
function updateCalendarUI(data, contextPath) { // 07-31: contextPath를 파라미터로 받음
    var calendarBody = $('#calendarBody'); // tbody 요소
    calendarBody.empty(); // 기존 달력 내용 비우기
    // 현재 월 표시 업데이트
    $('#currentMonthDisplay').text(data.currentYear + '년 ' + data.currentMonth + '월');
    // 이전/다음 달 버튼의 onclick 속성 업데이트 (매우 중요!)
    $('button.calendar-nav:contains("이전 달")').attr('onclick', 'changeMonth(' + data.prevMonthYear + ',' + data.prevMonth + ')'); // 07-31: 버튼 onclick 재설정
    $('button.calendar-nav:contains("다음 달")').attr('onclick', 'changeMonth(' + data.nextMonthYear + ',' + data.nextMonth + ')'); // 07-31: 버튼 onclick 재설정
    // 캘린더 tbody 내용 생성
    data.calendarWeeks.forEach(function(week) {
        var row = $('<tr>');
        week.forEach(function(dayData) {
            var cell = $('<td>');
            cell.addClass(dayData.todayStatus ? 'today' : ''); // 07-31: getter 이름 변경 반영
            cell.addClass(!dayData.currentMonthStatus ? 'other-month' : ''); // 07-31: getter 이름 변경 반영
            // 날짜 숫자
            var dateObj = new Date(dayData.date);
            cell.append($('<span class="day-number">').text(dateObj.getDate()));
            // 영화 포스터 컨테이너
            var posterContainer = $('<div class="movie-poster-container">');
            if (dayData.movies && dayData.movies.length > 0) {
                var posterCount = dayData.movies.length;
                dayData.movies.forEach(function(movie) {
                    var posterSrc = '';
                    
                    if (movie.posterPath && (movie.posterPath.startsWith('http://') || movie.posterPath.startsWith('https://'))) {
                        posterSrc = movie.posterPath; // 외부 URL인 경우 그대로 사용
                    } else if (movie.posterPath) {
                        posterSrc = contextPath + movie.posterPath; // 07-31: contextPath 적용
                    } else {
                        posterSrc = contextPath + '/resources/images/movies/256px-No-Image-Placeholder.png'; // 07-31: 기본 이미지 컨텍스트 패스 적용
                    }
                    var imgClass = 'movie-poster';
                    if (posterCount === 2) { imgClass += ' small'; }
                    else if (posterCount >= 3) { imgClass += ' smaller'; }
                    var movieLink = $('<a class="movie-link">').attr('href', contextPath + '/movies/' + movie.id); // 07-31: 링크에도 contextPath 적용
                    var img = $('<img>').attr('src', posterSrc).attr('alt', movie.title + ' 포스터').addClass(imgClass);
                    movieLink.append(img);
                    posterContainer.append(movieLink);
                });
            }
            cell.append(posterContainer);
            row.append(cell);
        });
        calendarBody.append(row);
    });
}
</script>
    