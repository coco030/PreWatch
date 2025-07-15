<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="rating-stars" data-movie-id="${movie.id}">
    <input type="hidden" name="memberId" value="${sessionScope.loginMember.id}" />
    <c:forEach var="i" begin="1" end="10">
        <span class="star" data-value="${i}">&#9733;</span>
    </c:forEach>
</div>

<script>
$(function() {
    const movieId = $('.rating-stars').data('movie-id');
    const memberId = $('input[name="memberId"]').val();
    let current = 0;

    $.get("/rating/get", {memberId, movieId}, function(res) {
        if (res && res.rating) {
            current = res.rating;
            drawStars(current);
        }
    });

    $('.star').click(function() {
        const value = $(this).data('value');
        const rating = (value === current) ? 0 : value;
        $.post("/rating/submit", {memberId, movieId, rating}, function() {
            current = rating;
            drawStars(current);
        });
    });

    function drawStars(value) {
        $('.star').each(function() {
            $(this).css('color', $(this).data('value') <= value ? 'gold' : 'lightgray');
        });
    }
});
</script>