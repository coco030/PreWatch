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



<div class="box p-4 border rounded mb-4 bg-light">
  <p><strong>${memberId}</strong>님의 영화 평가 성향을 요약해드릴게요 🙂</p>

  <ul class="mb-0">
    <li>총 <strong>${userRatingCount}</strong>개의 영화에 만족도 별점을 주셨고, 평균 별점은 <strong><fmt:formatNumber value="${averageUserRating}" maxFractionDigits="1"/></strong>점입니다.</li>
    <li>총 <strong>${violenceScoreCount}</strong>개의 영화에 폭력성 점수를 주셨고, 평균 점수는 <strong><fmt:formatNumber value="${averageViolenceScore}" maxFractionDigits="1"/></strong>점입니다.</li>
    <li>긍정적인 평가(★8 이상)는 <strong>${positiveRatingTotal}</strong>회, 부정적인 평가(★4 이하)는 <strong>${negativeRatingTotal}</strong>회 이루어졌습니다.</li>
    <c:if test="${not empty sortedGenreStats}">
      <li>자주 평가한 장르는 
        <c:forEach var="entry" items="${sortedGenreStats}" varStatus="loop">
          <c:set var="genre" value="${entry.key}" />
          <c:set var="count" value="${entry.value}" />
          <c:if test="${count > 0 && loop.index lt 3}">
            <strong>${genre}</strong>(${count}회)<c:if test="${loop.index lt 2}">, </c:if>
          </c:if>
        </c:forEach>
        입니다.
      </li>
    </c:if>
  </ul>

  <p class="mt-2">
    <c:choose>
      <c:when test="${averageUserRating >= 7.5}">만족도가 높은 편이며 </c:when>
      <c:when test="${averageUserRating >= 6}">평균적인 만족도를 보이며 </c:when>
      <c:otherwise>다소 냉정한 평가 경향이 있으며 </c:otherwise>
    </c:choose>
    <c:choose>
      <c:when test="${averageViolenceScore >= 7}">폭력 수위가 높은 영화도 자주 감상하시는 경향이 있습니다.</c:when>
      <c:otherwise>비교적 폭력성이 낮은 영화를 선호하시는 편입니다.</c:otherwise>
    </c:choose>
  </p>

  <p class="text-muted">전반적으로 <strong>
    <c:choose>
      <c:when test="${positiveCount >= negativeCount * 2}">관대한 평가 경향</c:when>
      <c:when test="${positiveCount <= negativeCount}">엄격한 평가 경향</c:when>
      <c:otherwise>균형 잡힌 평가 경향</c:otherwise>
    </c:choose>
  </strong>을 보이십니다.</p>
</div>



<!-- 요약과 겹쳐서 주석처리함. 

이걸 사용할 시엔 이렇게 뜸.

2님은 Action(1회), Adventure(1회), Fantasy(1회) 장르를 많이 평가하셨어요!

긍정적으로 평가한 영화가 적어 통계가 아직 없어요.

부정적으로 평가하신 영화가 적어 통계가 아직 없어요.

2님이 1개의 영화에 주신 평균 만족도 별점은 7점입니다.

2님이 1개의 영화에 주신 평균 폭력성 점수는 5점입니다.


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
</c:choose> -->

