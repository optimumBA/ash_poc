export default InfiniteScroll = {
  mounted() {
    this.observer = new IntersectionObserver(
      this.handleIntersection.bind(this),
      {
        threshold: 0.1,
        rootMargin: "100px",
      }
    );
    this.observer.observe(this.el);
  },

  destroyed() {
    if (this.observer) {
      this.observer.disconnect();
      this.observer = null;
    }
  },

  handleIntersection(entries) {
    const [entry] = entries;
    if (entry && entry.isIntersecting) {
      this.pushEvent("load-more");
    }
  },
};

// export default InfiniteScroll;

// TODO: This works too, so I'll keep it here for future use
// const InfiniteScroll = {
//   mounted() {
//     this.observer = new IntersectionObserver((entries) => {
//       const entry = entries[0];
//       if (entry.isIntersecting) {
//         this.pushEvent("load-more", {});
//       }
//     });
//     this.observer.observe(this.el);
//   },
//   destroyed() {
//     this.observer.disconnect();
//   },
// };

// export default InfiniteScroll;
