<%-- admin/bannerMovieManage.jsp (7-24 오후12:41 추가 된 코드) --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>추천 영화 관리</title>
    <link rel="stylesheet" href="<c:url value='/resources/css/style.css'/>">
    <style>
        /* CSS는 이전과 동일하게 유지됩니다. (7-24 오후12:41 추가 된 코드) */
        .container {
            max-width: 900px;
            margin: 30px auto;
            padding: 20px;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        h2 {
            text-align: center;
            color: #333;
            margin-bottom: 25px;
        }
        .message {
            padding: 10px;
            margin-bottom: 15px;
            border-radius: 5px;
            text-align: center;
            font-weight: bold;
        }
        .success-message {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .error-message {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .section-box {
            border: 1px solid #eee;
            padding: 20px;
            margin-bottom: 30px;
            border-radius: 8px;
            background-color: #f9f9f9;
        }
        .section-box h3 {
            margin-top: 0;
            margin-bottom: 15px;
            color: #555;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
        }
        .movie-selection label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
        }
        .movie-selection select {
            width: calc(100% - 100px); /* 버튼 공간 확보 */
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            margin-right: 10px;
            display: inline-block;
            vertical-align: middle;
        }
        .movie-selection button {
            padding: 10px 20px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s ease;
            vertical-align: middle;
        }
        .movie-selection button:hover {
            background-color: #0056b3;
        }
        .current-movies ul {
            list-style: none;
            padding: 0;
        }
        .current-movies li {
            background-color: #fff;
            border: 1px solid #ddd;
            padding: 12px 15px;
            margin-bottom: 10px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-radius: 4px;
        }
        .current-movies li span {
            font-weight: bold;
        }
        .current-movies li form {
            margin: 0;
            display: inline-block;
        }
        .current-movies li button {
            background-color: #dc3545;
            color: white;
            padding: 8px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        .current-movies li button:hover {
            background-color: #c82333;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>관리자 - 수동 추천 영화 관리</h2>

        <c:if test="${not empty successMessage}">
            <div class="message success-message">${successMessage}</div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="message error-message">${errorMessage}</div>
        </c:if>

        <div class="section-box">
            <h3>추천 영화 추가</h3>
            <form action="<c:url value='/admin/banner-movies/add'/>" method="post" class="movie-selection">
                <label for="movieSelect">추천할 영화 선택:</label>
                <select id="movieSelect" name="movieId" required>
                    <option value="">-- 영화를 선택하세요 --</option>
                    <c:forEach var="movie" items="${allMovies}">
                        <option value="${movie.id}">${movie.title} (${movie.year})</option>
                    </c:forEach>
                </select>
                <button type="submit">추가</button>
            </form>
        </div>

        <div class="section-box">
            <h3>현재 수동 추천 영화 목록</h3>
            <c:choose>
                <c:when test="${not empty currentAdminBannerMovies}">
                    <ul class="current-movies">
                        <c:forEach var="movie" items="${currentAdminBannerMovies}">
                            <li>
                                <span>${movie.title} (${movie.year})</span>
                                <form action="<c:url value='/admin/banner-movies/delete'/>" method="post" onsubmit="return confirm('정말로 이 영화를 추천 목록에서 삭제하시겠습니까?');">
                                    <input type="hidden" name="movieId" value="${movie.id}">
                                    <button type="submit">삭제</button>
                                </form>
                            </li>
                        </c:forEach>
                    </ul>
                </c:when>
                <c:otherwise>
                    <p>현재 수동 추천 영화로 등록된 영화가 없습니다.</p>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</body>
</html>
