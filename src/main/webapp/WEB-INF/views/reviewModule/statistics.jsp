<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.Map, java.util.List, java.util.ArrayList, java.util.Map.Entry" %>

<%
    Object raw = request.getAttribute("genreStats");
    if (raw != null && raw instanceof Map) {
        Map<String, Integer> stats = (Map<String, Integer>) raw;
        List<Map.Entry<String, Integer>> sortedStats = new ArrayList<>(stats.entrySet());
        sortedStats.sort((a, b) -> b.getValue() - a.getValue());
        pageContext.setAttribute("sortedGenreStats", sortedStats);
    } else {
        pageContext.setAttribute("sortedGenreStats", java.util.Collections.emptyList());
    }
%>

<!-- 자주 평가한 장르 -->
<c:choose>
  <c:when test="${not empty sortedGenreStats}">
    <div class="box p-3 border rounded">
     
      <p><strong>${memberId}</strong>님은
        <c:forEach var="entry" items="${sortedGenreStats}" varStatus="loop">
          <c:set var="genre" value="${entry.key}" />
          <c:set var="count" value="${entry.value}" />
          <c:if test="${count > 0 && loop.index lt 3}">
            <strong>${genre}</strong>(${count}회)<c:if test="${loop.index lt 2}">, </c:if>
          </c:if>
        </c:forEach>
        장르를 많이 평가하셨어요!
      </p>
    </div>
  </c:when>
  <c:otherwise>
    <p class="text-muted">자주 평가한 장르가 적어 통계가 아직 없어요.</p>
  </c:otherwise>
</c:choose>

<!-- 긍정적으로 평가한 장르 -->
<c:set var="hasPositive" value="false" />
<c:forEach var="entry" items="${positiveGenreStats}">
  <c:if test="${entry.value > 0}">
    <c:set var="hasPositive" value="true" />
  </c:if>
</c:forEach>

<c:choose>
  <c:when test="${hasPositive}">
    <div class="box p-3 border rounded mt-4">
    
      <p><strong>${memberId}</strong>님은
        <c:forEach var="entry" items="${positiveGenreStats}" varStatus="loop">
          <c:set var="genre" value="${entry.key}" />
          <c:set var="count" value="${entry.value}" />
          <c:if test="${count > 0 && loop.index lt 3}">
            <strong>${genre}</strong>(${count}회)<c:if test="${loop.index lt 2}">, </c:if>
          </c:if>
        </c:forEach>
        장르에 긍정적인 점수를 많이 주셨네요!
      </p>
    </div>
  </c:when>
  <c:otherwise>
    <p class="text-muted">긍정적으로 평가한 영화가 적어 통계가 아직 없어요.</p>
  </c:otherwise>
</c:choose>

<!-- 부정적으로 평가한 장르 -->
<c:set var="hasNegative" value="false" />
<c:forEach var="entry" items="${negativeGenreStats}">
  <c:if test="${entry.value > 0}">
    <c:set var="hasNegative" value="true" />
  </c:if>
</c:forEach>

<c:choose>
  <c:when test="${hasNegative}">
    <div class="box p-3 border rounded mt-4">
    
      <p><strong>${memberId}</strong>님은 
        <c:forEach var="entry" items="${negativeGenreStats}" varStatus="loop">
          <c:set var="genre" value="${entry.key}" />
          <c:set var="count" value="${entry.value}" />
          <c:if test="${count > 0 && loop.index lt 3}">
            <strong>${genre}</strong>(${count}회)<c:if test="${loop.index lt 2}">, </c:if>
          </c:if>
        </c:forEach>
        장르에 부정적인 점수를 많이 주셨네요!
      </p>
    </div>
  </c:when>
  <c:otherwise>
    <p class="text-muted">부정적으로 평가하신 영화가 적어 통계가 아직 없어요.</p>
  </c:otherwise>
</c:choose>

<!-- 평균 만족도 -->
<c:choose>
  <c:when test="${not empty averageUserRating}">
    <div class="box p-3 border rounded mt-4">
   
      <p>
        <strong>${memberId}</strong>님이 
        <strong>${userRatingCount}</strong>개의 영화에 주신 평균 만족도 별점은
        <strong><fmt:formatNumber value="${averageUserRating}" maxFractionDigits="1" /></strong>점입니다.
      </p>
    </div>
  </c:when>
  <c:otherwise>
    <p class="text-muted">평가하신 장르가 적어 아직 평균 만족도 점수 기록이 없어요.</p>
  </c:otherwise>
</c:choose>

<!-- 평균 폭력성 -->
<c:choose>
  <c:when test="${not empty averageViolenceScore}">
    <div class="box p-3 border rounded mt-4">
  
      <p>
        <strong>${memberId}</strong>님이 
        <strong>${violenceScoreCount}</strong>개의 영화에 주신 평균 폭력성 점수는
        <strong><fmt:formatNumber value="${averageViolenceScore}" maxFractionDigits="1" /></strong>점입니다.
      </p>
    </div>
  </c:when>
  <c:otherwise>
    <p class="text-muted">평가하신 장르가 적어 아직 평균 폭력성 점수 기록이 없어요.</p>
  </c:otherwise>
</c:choose>

