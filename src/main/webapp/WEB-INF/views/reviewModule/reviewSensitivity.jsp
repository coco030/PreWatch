<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%System.out.println("reviewSensitivity 진입"); %>
<%-- 폭력성 분류 출력 모듈 --%>
<c:choose>
    <c:when test="${movie.violence_score_avg >= 7}">
        <div class="alert alert-danger">
            ⚠️ 이 영화는 사용자 평가 기준으로 폭력성이 매우 높아요.
        </div>
    </c:when>
    <c:when test="${movie.violence_score_avg >= 4}">
        <div class="alert alert-warning">
            이 영화는 일부 사용자에게 폭력성이 높게 평가되었어요.
        </div>
    </c:when>
    <c:when test="${movie.violence_score_avg > 0}">
        <div class="alert alert-secondary">
            이 영화는 대체로 안전한 콘텐츠로 평가되었어요.
        </div>
    </c:when>
    <c:otherwise>
        <div class="alert alert-light">
            아직 리뷰가 충분하지 않아 폭력성 정보를 제공할 수 없어요. 평가해주시겠어요?
        </div>
    </c:otherwise>
</c:choose>