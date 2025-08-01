<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>나의 취향 분석 리포트</title>
    
    <%-- 전체 레이아웃을 위한 CSS  --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/layout.css">
    
    <%-- 이 페이지의 콘텐츠를 보기 좋게 꾸미기 위한 간단한 스타일 --%>
    <style>
        .taste-container {
            max-width: 800px;
            margin: 40px auto;
            padding: 40px;
            background-color: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            font-family: 'Noto Sans KR', sans-serif;
        }
        .page-title {
            text-align: center;
            font-size: 2em;
            font-weight: 700;
            color: #333;
            margin-bottom: 30px;
        }
        .taste-title-box {
            text-align: center;
            padding: 20px;
            background-color: #f8f9fa;
            border-radius: 8px;
            margin-bottom: 25px;
        }
        .taste-title {
            font-size: 1.7em;
            color: #2980b9; /* 포인트 컬러 */
            margin: 0;
        }
        .taste-report {
            font-size: 1.1em;
            line-height: 1.8;
            color: #555;
            text-align: left;
            padding: 0 10px;
        }
    </style>
</head>
<body>
    <%-- 공통 헤더 포함 --%>
    <jsp:include page="/WEB-INF/views/layout/header.jsp" />

    <div class="taste-container">
        <h1 class="page-title">My Taste Profile</h1>

        <%-- 컨트롤러에서 받은 memberInfo 객체의 데이터를 출력 --%>
        
        <%-- 취향 타이틀을 표시하는 부분 --%>
        <div class="taste-title-box">
            <c:if test="${not empty memberInfo.tasteTitle}">
                <h2 class="taste-title">"${memberInfo.tasteTitle}"</h2>
            </c:if>
            <c:if test="${empty memberInfo.tasteTitle}">
                <h2 class="taste-title">"취향 탐색 중"</h2>
            </c:if>
        </div>

        <%-- 취향 리포트(설명)를 표시하는 부분 --%>
        <c:if test="${not empty memberInfo.tasteReport}">
            <p class="taste-report">${memberInfo.tasteReport}</p>
        </c:if>

    </div>

    <%-- 공통 푸터 포함 --%>
    <jsp:include page="/WEB-INF/views/layout/footer.jsp" />
</body>
</html>