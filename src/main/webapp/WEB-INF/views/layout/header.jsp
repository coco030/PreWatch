<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>PreWatch</title>
    <link rel="stylesheet" href="<c:url value='/resources/css/layout.css'/>">
    <style>
        .header-wrapper 
        {	display: flex;
            justify-content: center;
            align-items: center;
            gap: 40px; }
    </style>
</head>
<body>
    <%-- 공통 헤더 --%>
    <div class="header-wrapper">
        <%@ include file="/WEB-INF/views/layout/header-left.jsp" %>
        <%@ include file="/WEB-INF/views/layout/header-center.jsp" %>
        <%@ include file="/WEB-INF/views/layout/header-right.jsp" %>
    </div>
</body>
</html>
