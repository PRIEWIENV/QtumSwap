import Vue from 'vue'
import Router from 'vue-router'
import Sender from '@/components/Sender'
import Receiver from '@/components/Receiver'
import formLoading from 'vue2-form-loading'

Vue.use(Router)
Vue.use(formLoading)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'home',
      component: Sender
    },
    {
      path: '/receiver',
      name: 'receiver',
      component: Receiver
    },
    {
      path: '/sender',
      name: 'sender',
      component: Sender
    }
  ]
})
