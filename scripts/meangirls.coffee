# Description:
#   Mean Girls gifs.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot mean girls

gifs = [
  "http://thoughtcatalog.files.wordpress.com/2013/08/mean-girls-33.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/burn_book.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/1359645312421318920.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/7pspv.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_m9zj6zmnmz1r4n0j3o1_500_large.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_m7ixzuaqbb1rwbl7wo1_500_large.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_mqe4reyh5b1s59ot0o1_500.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/mean-girls-movie-quotes-63.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_m6e0yzqopn1rys4czo1_500.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/mean-girls-gif-cady-heron-lindsay-lohan-falls-in-trash-can1.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_m1pzoovbqk1qfxq87o1_500.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_inline_mqtwtnotnw1qz4rgp.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_m4ln1w9nby1qdv2s8o1_500.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_m4jnoucxgf1ruj35mo1_500.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_lo4qyrsksq1qdqlhzo1_500.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/da-best-3-mean-girls-30385539-500-240.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_mn8cfyqlpl1rvkb0to1_500.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_m1it4db86j1rn95k2o1_500.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/mean-girls-movie-quotes-50-1.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/mean-girls-movie-quotes-46.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/picgifs-mean-girls-621550.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_m97qaucari1rbw6bto1_500.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_md2k35kh3h1ro2d43.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_m4qubfsitp1r6y67yo1_500.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_m6glxrkbfx1qbya5eo1_500.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_mbcmwkezai1r1x67e_large.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_m724kczt6q1rvbafdo1_500_large.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/mean-girls-6.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/mean-girls-3-mean-girls-21088336-500-254.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_lrr8qflxgt1qbkkwqo1_500.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_m24tolv8jc1rn435g.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/aahhh__meangirls.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_mm1momxlhc1qcoi5zo1_500.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_lmmzpcwndf1qiggm3o1_500.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/original-1.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/original.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_lumrmvvduh1qg5m9xo1_500.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_mcfbrckd541re7pd6o1_500.gif",
  "http://thoughtcatalog.files.wordpress.com/2013/08/tumblr_ly6080kgb51rnr4cho1_500.gif"
]

module.exports = (robot) ->
  robot.respond /mean[ ]?girls$/i, (msg) ->
    msg.send msg.random(gifs)
