<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
<head>
    <title>전체 영화 주의 요소 관리</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
    body { font-family: sans-serif; margin: 0; background-color: #f4f4f4; }
    .container { width: 100%; max-width: 1200px; margin: 0 auto; background-color: #fff; padding: 15px; }
    h1 { font-size: 1.8em; }
    h1, .page-description { text-align: center; }
    .controls { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding-bottom: 20px; border-bottom: 1px solid #eee; }
    .controls.bottom { border-bottom: none; border-top: 1px solid #eee; margin-top: 20px; padding-top: 20px; display: flex; justify-content: space-between; align-items: center; }
    
    /* 링크 스타일 (기본 파란색) */
    .back-link, .go-to-top-link {
        font-size: 1em;
        text-decoration: underline;
        color: #007bff; /* 기본 파란색 링크 */
    }
    .back-link:hover, .go-to-top-link:hover {
        text-decoration: underline;
    }

    /* 변경사항 저장 버튼 스타일 */
    .submit-button { 
        padding: 8px 16px; 
        font-size: 1em; 
        cursor: pointer; 
        background-color: #007bff; /* 파란색 배경 */
        color: white; 
        border: none; 
        border-radius: 5px; 
        transition: background-color 0.3s ease;
    }
    .submit-button:hover {
        background-color: #0056b3; /* hover 시 어두운 파란색 */
    }
    
    /* --- 데스크탑용 카드 레이아웃 --- */
    .movie-card { display: flex; border: 1px solid #ddd; border-radius: 8px; margin-bottom: 20px; overflow: hidden; }
    .poster-section { flex: 0 0 150px; }
    .poster-section img { width: 100%; height: auto; display: block; }
    .info-section { flex: 1; padding: 20px; display: flex; }
    .movie-details { flex: 0 0 250px; border-right: 1px solid #eee; padding-right: 20px; }
    .movie-title { font-weight: bold; font-size: 1.4em; margin-bottom: 10px; }
    .movie-rating-badge { display: inline-block; padding: 4px 8px; background-color: #6c757d; color: white; border-radius: 4px; font-size: 0.9em; margin-top: 10px; }
    .tags-section { flex: 1; padding-left: 20px; }
    .tag-group { margin-bottom: 15px; }
    .tag-group-title { font-weight: bold; color: #333; border-bottom: 2px solid #eee; padding-bottom: 5px; margin-bottom: 10px; }
    .checkbox-item { display: block; margin-bottom: 8px; }
    
    /* --- 페이지네이션 버튼 스타일 변경 --- */
    .pagination { text-align: center; margin-top: 30px; }
    .pagination button { 
        padding: 8px 12px; 
        margin: 0 5px; 
        cursor: pointer; 
        border: 1px solid #e0e0e0; /* 연한 회색 테두리 */
        background-color: #f0f0f0; /* 연한 회색 배경 */
        border-radius: 5px; /* 살짝 둥근 테두리 */
        color: #333; /* 텍스트 색상 */
    }
    .pagination button:hover:not(:disabled) {
        background-color: #e9e9e9; /* 호버 시 약간 더 진한 회색 */
    }
    .pagination button.active { 
        background-color: #007bff; 
        color: white; 
        border-color: #007bff; 
    }
    .pagination button:disabled { 
        cursor: not-allowed; 
        opacity: 0.5; 
    }

    /*모바일 반응형 */
    /* 화면 너비가 768px 이하일 때 적용 */
    @media (max-width: 768px) {
        .container { padding: 10px; }
        h1 { font-size: 1.5em; }
        .page-description { font-size: 0.9em; }
        
        /* 카드 레이아웃을 세로로 변경 */
        .movie-card, .info-section {
            flex-direction: column;
        }
        .poster-section {
            /* 포스터 영역을 카드 너비에 맞춤 */
            flex-basis: auto; 
            width: 100%;
            text-align: center; /* 포스터 가운데 정렬 */
        }
        .poster-section img {
            width: 50%; /* 포스터 너비를 절반으로 줄임 */
            margin: 0 auto;
        }
        .info-section {
            padding: 15px;
        }
        .movie-details {
            flex-basis: auto;
            border-right: none; /* 세로 구분선 제거 */
            border-bottom: 1px solid #eee; /* 가로 구분선 추가 */
            padding-right: 0;
            padding-bottom: 15px;
            margin-bottom: 15px;
        }
        .tags-section {
            padding-left: 0;
        }
    }
</style>
</head>
<body>
<div class="container">
    <h1 id="top">전체 영화 주의 요소 관리</h1>
    <p class="page-description">영화 포스터와 등급 정보를 참고하여 주의 요소를 설정하고 저장할 수 있습니다.</p>

    <c:if test="${param.update == 'success'}">
        <p style="color: green; font-weight: bold; text-align: center;">성공적으로 저장되었습니다!</p>
    </c:if>

    <form action="<c:url value='/admin/warnings/all'/>" method="post">

        <div id="movie-list-container">
            <%-- 영화 카드 --%>
            <c:forEach items="${allMovies}" var="movie">
                <div class="movie-card">
                    <div class="poster-section">
                        <c:set var="posterSrc">
                            <c:choose>
                                <c:when test="${not empty movie.posterPath and movie.posterPath ne 'N/A'}">
                                    <c:if test="${fn:startsWith(movie.posterPath, 'http')}">${movie.posterPath}</c:if>
                                    <c:if test="${not fn:startsWith(movie.posterPath, 'http')}">${pageContext.request.contextPath}${movie.posterPath}</c:if>
                                </c:when>
                                <c:otherwise>${pageContext.request.contextPath}/resources/images/placeholder.png</c:otherwise>
                            </c:choose>
                        </c:set>
                        <img src="${posterSrc}" alt="${movie.title} 포스터">
                    </div>
                    <div class="info-section">
                        <div class="movie-details">
                            <div class="movie-title">${movie.title} (${movie.year})</div>
                            <c:if test="${not empty movie.rated and movie.rated ne 'N/A'}">
                                <span class="movie-rating-badge">등급: ${movie.rated}</span>
                            </c:if>
                        </div>
                        <div class="tags-section">
                            <c:forEach items="${allTagsGrouped}" var="categoryEntry">
                                <div class="tag-group">
                                    <div class="tag-group-title">${categoryEntry.key}</div>
                                    <c:forEach items="${categoryEntry.value}" var="tag">
                                        <label class="checkbox-item">
                                            <input type="checkbox" name="tags_${movie.id}" value="${tag.id}"
                                                <c:if test="${movieToSelectedTagsMap[movie.id].contains(tag.id)}">checked</c:if>
                                            >
                                            ${tag.sentence}
                                        </label>
                                    </c:forEach>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>

        <div class="pagination" id="pagination-controls"></div>
        
        <div class="controls bottom">
            <a href="<c:url value='/movies'/>" class="back-link">« 영화 목록으로</a>
            <a href="#top" class="go-to-top-link">맨 위로</a>
            <button type="submit" class="submit-button">변경사항 저장</button>
        </div>
    </form>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const rowsPerPage = 2; 
        const container = document.getElementById('movie-list-container');
        const cards = container.querySelectorAll('.movie-card');
        const paginationControls = document.getElementById('pagination-controls');
        
        if (cards.length === 0) return;

        const pageCount = Math.ceil(cards.length / rowsPerPage);

        if (pageCount <= 1) {
            paginationControls.style.display = 'none';
            return;
        }

        let currentPage = 1;

        function displayPage(page) {
            currentPage = page;
            const start = (page - 1) * rowsPerPage;
            const end = start + rowsPerPage;
            
            // 모바일에서는 'block', 데스크탑에서는 'flex'
            const displayStyle = window.innerWidth <= 768 ? 'block' : 'flex';
            
            cards.forEach((card, index) => {
                card.style.display = (index >= start && index < end) ? displayStyle : 'none';
            });
            updatePaginationButtons();
        }

        function createPaginationButtons() {
            const prevButton = document.createElement('button');
            prevButton.textContent = '이전';
            prevButton.id = 'prev-button';
            prevButton.addEventListener('click', () => { if (currentPage > 1) displayPage(currentPage - 1); });
            paginationControls.appendChild(prevButton);

            for (let i = 1; i <= pageCount; i++) {
                const button = document.createElement('button');
                button.textContent = i;
                button.classList.add('page-button');
                button.dataset.page = i;
                button.addEventListener('click', () => displayPage(i));
                paginationControls.appendChild(button);
            }
            
            const nextButton = document.createElement('button');
            nextButton.textContent = '다음';
            nextButton.id = 'next-button';
            nextButton.addEventListener('click', () => { if (currentPage < pageCount) displayPage(currentPage + 1); });
            paginationControls.appendChild(nextButton);
        }

        function updatePaginationButtons() {
            document.querySelectorAll('.page-button').forEach(button => {
                button.classList.toggle('active', parseInt(button.dataset.page) === currentPage);
            });
            document.getElementById('prev-button').disabled = (currentPage === 1);
            document.getElementById('next-button').disabled = (currentPage === pageCount);
        }

        createPaginationButtons();
        displayPage(1);

        // 창 크기가 변경될 때 레이아웃
        window.addEventListener('resize', () => displayPage(currentPage));
    });
</script>

</body>
</html>